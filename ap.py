import tensorflow as tf

# Cargar y convertir
model = tf.keras.models.load_model('keras_model.h5', compile=False)
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Guardar
with open('keras_model.tflite', 'wb') as f:
    f.write(tflite_model)
    
print("✅ Conversión exitosa")
                