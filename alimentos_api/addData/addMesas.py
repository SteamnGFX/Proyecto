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

# IDs de meseros y corredores (deben coincidir con los IDs en tu base de datos)
mesero_ids = [2, 3, 4, 5]  # IDs de meseros
corredor_ids = [6, 7, 8, 9]  # IDs de corredores

# Creación de mesas, 5 para cada mesero y corredor
mesas = []
mesa_numero = 1

for mesero_id in mesero_ids:
    for i in range(5):  # Cada mesero tendrá 5 mesas
        mesa = {
            'mesa_id': get_next_sequence('mesa_id'),
            'numero': mesa_numero,
            'estatus': '',
            'mesero_id': mesero_id,
            'cliente': '',
            'comanda': 0,
            'corredor_id': corredor_ids[mesero_ids.index(mesero_id)]
        }
        mesas.append(mesa)
        mesa_numero += 1

# Insertar mesas en la colección de mesas
db.mesas.insert_many(mesas)

print("Mesas agregadas exitosamente.")
