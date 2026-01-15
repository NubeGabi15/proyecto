import os
import json
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime
from collections import Counter

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
from sklearn.metrics import confusion_matrix, classification_report

# -------- Ajustes principales --------
DATASET_DIR = "Fruta"          # Ruta a tu dataset
IMG_SIZE = (256, 256)            # Mejor precisión que 224x224
BATCH_SIZE = 32
VAL_SPLIT = 0.20
SEED = 42

EPOCHS_HEAD = 20
EPOCHS_FT = 12

MODEL_NAME = f"modelo_frutas_{datetime.now().strftime('%Y%m%d_%H%M')}"

# Salidas
OUT_DIR = "outputs"
os.makedirs(OUT_DIR, exist_ok=True)
MODEL_PATH_KERAS = os.path.join(OUT_DIR, f"{MODEL_NAME}.keras")
LABELS_PATH = os.path.join(OUT_DIR, f"{MODEL_NAME}_labels.json")
REPORT_PATH = os.path.join(OUT_DIR, f"{MODEL_NAME}_report.txt")
CM_PATH = os.path.join(OUT_DIR, f"{MODEL_NAME}_cm.png")
HIST_PATH = os.path.join(OUT_DIR, f"{MODEL_NAME}_history.png")

print("TensorFlow:", tf.__version__)
print("Dataset dir:", os.path.abspath(DATASET_DIR))

# -------- Carga del dataset --------
train_ds = tf.keras.utils.image_dataset_from_directory(
    DATASET_DIR,
    validation_split=VAL_SPLIT,
    subset="training",
    seed=SEED,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE
)
val_ds = tf.keras.utils.image_dataset_from_directory(
    DATASET_DIR,
    validation_split=VAL_SPLIT,
    subset="validation",
    seed=SEED,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE
)

class_names = train_ds.class_names
num_classes = len(class_names)
print("Clases detectadas:", class_names)

AUTOTUNE = tf.data.AUTOTUNE
train_ds = train_ds.shuffle(1000).prefetch(AUTOTUNE)
val_ds = val_ds.prefetch(AUTOTUNE)

# -------- Data augmentation (fuerte) --------
data_augmentation = keras.Sequential([
    layers.RandomFlip("horizontal"),
    layers.RandomRotation(0.08),
    layers.RandomZoom(0.12),
    layers.RandomTranslation(0.08, 0.08),
    layers.RandomContrast(0.15),
    layers.RandomBrightness(0.15),
], name="augmentation")

# -------- Modelo base (transfer learning) --------
base_model = keras.applications.MobileNetV2(
    input_shape=IMG_SIZE + (3,),
    include_top=False,
    weights="imagenet"
)
base_model.trainable = False

preprocess_input = keras.applications.mobilenet_v2.preprocess_input

inputs = keras.Input(shape=IMG_SIZE + (3,))
x = data_augmentation(inputs)
x = preprocess_input(x)
x = base_model(x, training=False)
x = layers.GlobalAveragePooling2D()(x)
x = layers.Dropout(0.3)(x)
outputs = layers.Dense(num_classes, activation="softmax")(x)

model = keras.Model(inputs, outputs, name="frutas_mobilenetv2")

loss_fn = keras.losses.SparseCategoricalCrossentropy()


model.compile(
    optimizer=keras.optimizers.Adam(1e-3),
    loss=loss_fn,
    metrics=["accuracy"]
)

model.summary()

# -------- Class weights (auto) --------
y_train = []
for _, yb in train_ds.unbatch():
    y_train.append(int(yb.numpy()))

counts = Counter(y_train)
total = sum(counts.values())
class_weight = {i: total/(len(counts)*counts[i]) for i in counts}

print("Class weights:", class_weight)

# -------- Callbacks --------
early_stop = keras.callbacks.EarlyStopping(
    monitor="val_loss",
    patience=6,
    restore_best_weights=True,
    verbose=1
)

reduce_lr = keras.callbacks.ReduceLROnPlateau(
    monitor="val_loss",
    factor=0.5,
    patience=2,
    min_lr=1e-7,
    verbose=1
)

checkpoint = keras.callbacks.ModelCheckpoint(
    MODEL_PATH_KERAS,
    monitor="val_loss",
    save_best_only=True,
    verbose=1
)

# -------- Entrenamiento (cabeza) --------
hist1 = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=EPOCHS_HEAD,
    callbacks=[early_stop, reduce_lr, checkpoint],
    class_weight=class_weight
)

# -------- Fine-tuning --------
unfreeze_from = -60
for layer in base_model.layers[unfreeze_from:]:
    layer.trainable = True

model.compile(
    optimizer=keras.optimizers.Adam(1e-5),
    loss=loss_fn,
    metrics=["accuracy"]
)

hist2 = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=EPOCHS_FT,
    callbacks=[early_stop, reduce_lr, checkpoint],
    class_weight=class_weight
)

# -------- Cargar mejor modelo --------
best_model = keras.models.load_model(MODEL_PATH_KERAS, compile=False)

# -------- Guardar etiquetas --------
labels_map = {i: name for i, name in enumerate(class_names)}
with open(LABELS_PATH, "w", encoding="utf-8") as f:
    json.dump(labels_map, f, ensure_ascii=False, indent=2)

print("Etiquetas guardadas en:", LABELS_PATH)

# -------- Evaluación --------
y_true, y_pred = [], []
for imgs, labels in val_ds:
    preds = best_model.predict(imgs, verbose=0)
    y_true.extend(labels.numpy())
    y_pred.extend(np.argmax(preds, axis=1))

y_true = np.array(y_true)
y_pred = np.array(y_pred)

report = classification_report(y_true, y_pred, target_names=class_names, digits=4)
print(report)

with open(REPORT_PATH, "w", encoding="utf-8") as f:
    f.write(report)

# -------- Matriz de confusión --------
cm = confusion_matrix(y_true, y_pred)
plt.figure(figsize=(10, 8))
plt.imshow(cm, cmap="Blues")
plt.title("Matriz de confusión")
plt.xlabel("Predicción")
plt.ylabel("Real")
plt.xticks(range(num_classes), class_names, rotation=90)
plt.yticks(range(num_classes), class_names)

for i in range(num_classes):
    for j in range(num_classes):
        plt.text(j, i, cm[i, j], ha="center", va="center")

plt.tight_layout()
plt.savefig(CM_PATH, dpi=200)
plt.close()

# -------- Curvas --------
def merge(hist1, hist2):
    merged = {"loss": [], "val_loss": [], "accuracy": [], "val_accuracy": []}
    if hist1:
        for k in merged: merged[k].extend(hist1.history.get(k, []))
    if hist2:
        for k in merged: merged[k].extend(hist2.history.get(k, []))
    return merged

merged = merge(hist1, hist2)

plt.figure(figsize=(10, 4.5))
plt.subplot(1, 2, 1)
plt.plot(merged["loss"], label="train")
plt.plot(merged["val_loss"], label="val")
plt.legend()
plt.title("Loss")

plt.subplot(1, 2, 2)
plt.plot(merged["accuracy"], label="train")
plt.plot(merged["val_accuracy"], label="val")
plt.legend()
plt.title("Accuracy")

plt.tight_layout()
plt.savefig(HIST_PATH, dpi=200)
plt.close()

print("\n✅ Entrenamiento completado.")
print("Modelo guardado:", MODEL_PATH_KERAS)
print("Etiquetas guardadas:", LABELS_PATH)
print("Reporte:", REPORT_PATH)
print("Matriz de confusión:", CM_PATH)
print("Curvas:", HIST_PATH)
