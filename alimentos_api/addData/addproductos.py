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

# Productos a insertar
productos = [
    {
        'producto_id': get_next_sequence('producto_id'),
        'nombre': 'Empanada de queso con chorizo',
        'descripcion': 'Empanada de pasta de hojaldre con queso y chorizo',
        'precio': 50.00,
        'categoria': 'comida'
    },
    {
        'producto_id': get_next_sequence('producto_id'),
        'nombre': 'Empanada hawaiana',
        'descripcion': 'Empanada de pasta de hojaldre con piña, jamón y queso',
        'precio': 50.00,
        'categoria': 'comida'
    },
    {
        'producto_id': get_next_sequence('producto_id'),
        'nombre': 'Empanada de pepperoni',
        'descripcion': 'Empanada de pasta de hojaldre con pepperoni y queso',
        'precio': 50.00,
        'categoria': 'comida'
    },
    {
        'producto_id': get_next_sequence('producto_id'),
        'nombre': 'Baguette de pollo',
        'descripcion': 'Baguette de pollo con papas tipo chips y aderezo a elegir: Mayonesa/chipotle/césar',
        'precio': 80.00,
        'categoria': 'comida'
    },
    {
        'producto_id': get_next_sequence('producto_id'),
        'nombre': 'Orden de nachos',
        'descripcion': 'Nachos preparados con queso y rodajas de chile jalapeño',
        'precio': 60.00,
        'categoria': 'comida'
    },
    {
        'producto_id': get_next_sequence('producto_id'),
        'nombre': 'Brownie con helado',
        'descripcion': 'Brownie acompañado de helado de vainilla',
        'precio': 70.00,
        'categoria': 'postre'
    },
    {
        'producto_id': get_next_sequence('producto_id'),
        'nombre': 'Crepa dulce',
        'descripcion': 'Crepa con base a elegir: Nutella, lechera, y fruta a elegir: Plátano, fresa, philadelphia',
        'precio': 60.00,
        'categoria': 'postre'
    },
    {
        'producto_id': get_next_sequence('producto_id'),
        'nombre': 'Piñada',
        'descripcion': 'Bebida refrescante de piña y crema de coco',
        'precio': 45.00,
        'categoria': 'bebida'
    },
    {
        'producto_id': get_next_sequence('producto_id'),
        'nombre': 'Malteada de fresa',
        'descripcion': 'Malteada cremosa de fresa',
        'precio': 55.00,
        'categoria': 'bebida'
    },
    {
        'producto_id': get_next_sequence('producto_id'),
        'nombre': 'Malteada de vainilla',
        'descripcion': 'Malteada cremosa de vainilla',
        'precio': 55.00,
        'categoria': 'bebida'
    },
    {
        'producto_id': get_next_sequence('producto_id'),
        'nombre': 'Malteada de chocolate',
        'descripcion': 'Malteada cremosa de chocolate',
        'precio': 55.00,
        'categoria': 'bebida'
    }
]

# Insertar productos en la colección de productos
db.productos.insert_many(productos)

print("Productos agregados exitosamente.")
