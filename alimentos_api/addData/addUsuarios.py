from pymongo import MongoClient

# Conectar a la base de datos MongoDB
client = MongoClient("mongodb+srv://programacion:Azis123@trazis.nwaxiwy.mongodb.net/Trazis")
db = client.Trazis

# Función para obtener el siguiente ID autoincremental
def get_next_sequence(name):
    sequence = db.counters.find_one_and_update(
        {'_id': name},
        {'$inc': {'seq': 1}},
        return_document=True,
        upsert=True
    )
    return sequence['seq']

# Función para insertar los usuarios base
def insertar_usuarios_base():
    usuarios_base = [
        {'nombre': 'Admin', 'email': 'admin@gmail.com', 'password': '123', 'rol': 'administrador'},
        {'nombre': 'Mesero1', 'email': 'mesero1@gmail.com', 'password': '123', 'rol': 'mesero'},
        {'nombre': 'Mesero2', 'email': 'mesero2@gmail.com', 'password': '123', 'rol': 'mesero'},
        {'nombre': 'Mesero3', 'email': 'mesero3@gmail.com', 'password': '123', 'rol': 'mesero'},
        {'nombre': 'Mesero4', 'email': 'mesero4@gmail.com', 'password': '123', 'rol': 'mesero'},
        {'nombre': 'Corredor1', 'email': 'corredor1@gmail.com', 'password': '123', 'rol': 'corredor'},
        {'nombre': 'Corredor2', 'email': 'corredor2@gmail.com', 'password': '123', 'rol': 'corredor'},
        {'nombre': 'Corredor3', 'email': 'corredor3@gmail.com', 'password': '123', 'rol': 'corredor'},
        {'nombre': 'Corredor4', 'email': 'corredor4@gmail.com', 'password': '123', 'rol': 'corredor'},
        {'nombre': 'Cajero', 'email': 'cajero@gmail.com', 'password': '123', 'rol': 'caja'},
        {'nombre': 'Cocina', 'email': 'cocina@gmail.com', 'password': '123', 'rol': 'cocina'},
        {'nombre': 'host', 'email': 'host@gmail.com', 'password': '123', 'rol': 'host'}
    ]
    
    for usuario in usuarios_base:
        if not db.usuarios.find_one({'email': usuario['email']}):
            usuario['usuario_id'] = get_next_sequence('usuario_id')
            db.usuarios.insert_one(usuario)
    
    print("Usuarios agregados exitosamente.")

# Ejecución de la función para insertar los usuarios
if __name__ == "__main__":
    insertar_usuarios_base()
