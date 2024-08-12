from flask import Flask, request, jsonify
from flask_pymongo import PyMongo
from flask_restful import Api, Resource
from flask_cors import CORS
import jwt 
import datetime
from bson import ObjectId
from pytz import utc

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})
api = Api(app)

app.config['MONGO_URI'] = "mongodb+srv://programacion:Azis123@trazis.nwaxiwy.mongodb.net/Trazis"
app.config['SECRET_KEY'] = '21000401'

mongo = PyMongo(app)

def str_id(document):
    document['_id'] = str(document['_id'])
    return document

def get_next_sequence(name):
    sequence = mongo.db.counters.find_one_and_update(
        {'_id': name},
        {'$inc': {'seq': 1}},
        return_document=True,
        upsert=True
    )
    return sequence['seq']

def convert_object_id(document):
    for key, value in document.items():
        if isinstance(value, ObjectId):
            document[key] = str(value)
    return document

def convert_mesa_id(document):
    document['id'] = document.pop('mesa_id')
    document['meseroId'] = document.pop('mesero_id')
    return document

class UsuarioResource(Resource):
    def get(self):
        usuarios = mongo.db.usuarios.find()
        return jsonify([str_id(usuario) for usuario in usuarios])

    def post(self):
        data = request.get_json()
        nuevo_usuario = {
            'usuario_id': get_next_sequence('usuario_id'),
            'nombre': data['nombre'],
            'email': data['email'],
            'password': data['password'],
            'rol': data['rol']
        }
        mongo.db.usuarios.insert_one(nuevo_usuario)
        return jsonify({'message': 'Usuario creado', 'usuario_id': nuevo_usuario['usuario_id']})

    def put(self, usuario_id):
        data = request.get_json()
        mongo.db.usuarios.update_one(
            {'usuario_id': usuario_id},
            {'$set': {
                'nombre': data['nombre'],
                'email': data['email'],
                'password': data['password'],
                'rol': data['rol']
            }}
        )
        return jsonify({'message': 'Usuario actualizado'})

    def delete(self, usuario_id):
        mongo.db.usuarios.delete_one({'usuario_id': usuario_id})
        return jsonify({'message': 'Usuario eliminado'})

api.add_resource(UsuarioResource, '/usuarios', '/usuarios/<int:usuario_id>')

class MesaResource(Resource):
    def get(self):
        mesas = mongo.db.mesas.find()
        mesas = [convert_mesa_id(convert_object_id(mesa)) for mesa in mesas]
        return jsonify(mesas)

    def post(self):
        data = request.get_json()
        nueva_mesa = {
            'mesa_id': get_next_sequence('mesa_id'),
            'numero': data['numero'],
            'estatus': data['estatus'],
            'mesero_id': data.get('mesero_id', None),
            'cliente': data.get('cliente', 'Libre'),
            'comanda': data.get('comanda', 0),
            'corredor_id': data.get('corredor_id', None)
        }
        mongo.db.mesas.insert_one(nueva_mesa)
        return jsonify({'message': 'Mesa creada', 'mesa_id': nueva_mesa['mesa_id']})

    def put(self, mesa_id):
        data = request.get_json()

        mesa_existente = mongo.db.mesas.find_one({'mesa_id': mesa_id})

        if not mesa_existente:
            return jsonify({'message': 'Mesa no encontrada'}), 404

        update_data = {
            'numero': data.get('numero', mesa_existente['numero']),
            'estatus': data.get('estatus', mesa_existente['estatus']),
            'cliente': data.get('cliente', mesa_existente['cliente']),
            'comanda': data.get('comanda', mesa_existente['comanda']),
            'mesero_id': mesa_existente['mesero_id'],  
            'corredor_id': mesa_existente['corredor_id'] 
        }

        mongo.db.mesas.update_one(
            {'mesa_id': mesa_id},
            {'$set': update_data}
        )

        return jsonify({'message': 'Mesa actualizada'})

    def delete(self, mesa_id):
        mongo.db.mesas.delete_one({'mesa_id': mesa_id})
        return jsonify({'message': 'Mesa eliminada'})

api.add_resource(MesaResource, '/mesas', '/mesas/<int:mesa_id>')

class EntregarComidaResource(Resource):
    def put(self, mesa_id):
        try:
            mongo.db.mesas.update_one(
                {'numero': int(mesa_id)},
                {'$set': {'estatus': 'comiendo'}}
            )
            return jsonify({'message': 'Mesa actualizada a comiendo'})
        except Exception as e:
            return jsonify({'error': str(e)}), 500

api.add_resource(EntregarComidaResource, '/entregar_comida/<int:mesa_id>')

class PedirCuentaResource(Resource):
    def put(self, mesa_id):
        try:
            mongo.db.mesas.update_one(
                {'numero': mesa_id},
                {'$set': {'estatus': 'cobrar'}}
            )
            return jsonify({'message': 'Mesa actualizada a cobrar'})
        except Exception as e:
            return jsonify({'error': str(e)}), 500

api.add_resource(PedirCuentaResource, '/pedircuenta/<int:mesa_id>')

class LimpiarMesaResource(Resource):
    def put(self, mesa_id):
        try:
            mongo.db.mesas.update_one(
                {'mesa_id': mesa_id},
                {'$set': {'estatus': 'libre', 'cliente': 'Libre', 'comanda': 0}}
            )
            return jsonify({'message': 'Mesa actualizada a libre'})
        except Exception as e:
            return jsonify({'error': str(e)}), 500

api.add_resource(LimpiarMesaResource, '/limpiar/<int:mesa_id>')

class PedidoResource(Resource):
    def get(self):
        pedido_id = request.args.get('pedido_id')
        mesa_id = request.args.get('mesa_id')
        comanda = request.args.get('comanda')

        if pedido_id:
            pedido = mongo.db.pedidos.find_one({'pedido_id': int(pedido_id)})
            if not pedido:
                return jsonify({'message': 'Pedido no encontrado'}), 404
            return jsonify(str_id(pedido))

        if mesa_id and comanda:
            pedidos = mongo.db.pedidos.find({'mesa_id': int(mesa_id), 'comanda': int(comanda)})
            return jsonify([str_id(pedido) for pedido in pedidos])

        pedidos = mongo.db.pedidos.find()
        return jsonify([str_id(pedido) for pedido in pedidos])

    def post(self):
        try:
            data = request.get_json()
            pedido_id = get_next_sequence('pedido_id')
            nuevo_pedido = {
                'pedido_id': pedido_id,
                'mesa_id': data['mesa_id'],
                'usuario_id': data['usuario_id'],
                'estatus': data['estatus'],
                'fecha': datetime.datetime.now(utc),
                'cliente': data.get('cliente', 'Desconocido'),
                'comanda': data['comanda'],
                'detalles': [] 
            }

            pedido_insertado = mongo.db.pedidos.insert_one(nuevo_pedido)
            pedido_id_str = str(pedido_insertado.inserted_id)

            detalles = []
            for detalle in data['detalles']:
                detalle['pedido_id'] = pedido_id
                detalle['id'] = get_next_sequence('detalle_id') 
                detalles.append(detalle)

            mongo.db.pedidos.update_one(
                {'_id': ObjectId(pedido_id_str)},
                {'$set': {'detalles': detalles}}
            )

            return jsonify({'message': 'Pedido creado', 'pedido_id': pedido_id})
        except Exception as e:
            return jsonify({'error': str(e)}), 500

    def put(self, pedido_id):
        try:
            data = request.get_json()

            update_data = {
                'estatus': data.get('estatus'),
                'fecha': data.get('fecha'),
            }

            if 'cliente' in data:
                update_data['cliente'] = data['cliente']
            if 'comanda' in data:
                update_data['comanda'] = data['comanda']

            mongo.db.pedidos.update_one(
                {'pedido_id': pedido_id},
                {'$set': update_data}
            )

            return jsonify({'message': 'Pedido actualizado'})
        except Exception as e:
            return jsonify({'error': str(e)}), 500

    def delete(self, pedido_id):
        try:
            mongo.db.pedidos.delete_one({'pedido_id': int(pedido_id)})
            return jsonify({'message': 'Pedido eliminado'})
        except Exception as e:
            return jsonify({'error': str(e)}), 500

api.add_resource(PedidoResource, '/pedidos', '/pedidos/<int:pedido_id>')

class PedidosListosResource(Resource):
    def get(self):
        try:
            pedidos = mongo.db.pedidos.find({'estatus': 'listo'})

            pedidos_list = [{
                'pedido_id': pedido['pedido_id'],
                'mesa_id': pedido['mesa_id'],
                'usuario_id': pedido['usuario_id'],
                'estatus': pedido['estatus'],
                'fecha': pedido['fecha'].isoformat() if isinstance(pedido['fecha'], datetime.datetime) else datetime.datetime.fromtimestamp(int(str(pedido['fecha']['$date'])[:10])).isoformat(),
                'detalles': pedido['detalles'],
                'comanda': pedido['comanda']
            } for pedido in pedidos]

            return jsonify(pedidos_list)
        except Exception as e:
            return jsonify({'error': str(e)}), 500

api.add_resource(PedidosListosResource, '/pedidos/listos')

class ProductoResource(Resource):
    def get(self, producto_id=None):
        if producto_id:
            producto = mongo.db.productos.find_one({'producto_id': int(producto_id)})
            return jsonify(str_id(producto))
        else:
            productos = mongo.db.productos.find()
            return jsonify([str_id(producto) for producto in productos])

    def post(self):
        data = request.get_json()
        nuevo_producto = {
            'producto_id': get_next_sequence('producto_id'),
            'nombre': data['nombre'],
            'descripcion': data.get('descripcion', ''),
            'precio': data['precio'],
            'categoria': data['categoria']
        }
        mongo.db.productos.insert_one(nuevo_producto)
        return jsonify({'message': 'Producto creado', 'producto_id': nuevo_producto['producto_id']})

    def put(self, producto_id):
        data = request.get_json()
        mongo.db.productos.update_one(
            {'producto_id': int(producto_id)},
            {'$set': {
                'nombre': data['nombre'],
                'descripcion': data.get('descripcion', ''),
                'precio': data['precio'],
                'categoria': data['categoria']
            }}
        )
        return jsonify({'message': 'Producto actualizado'})

    def delete(self, producto_id):
        mongo.db.productos.delete_one({'producto_id': int(producto_id)})
        return jsonify({'message': 'Producto eliminado'})

api.add_resource(ProductoResource, '/productos', '/productos/<int:producto_id>')

class DetallePedidoResource(Resource):
    def get(self):
        detalles = mongo.db.detalles_pedido.find()
        return jsonify([str_id(detalle) for detalle in detalles])

    def post(self):
        data = request.get_json()
        nuevo_detalle = {
            'detalle_pedido_id': get_next_sequence('detalle_pedido_id'),
            'pedido_id': data['pedido_id'],
            'producto_id': data['producto_id'],
            'cantidad': data['cantidad']
        }
        mongo.db.detalles_pedido.insert_one(nuevo_detalle)
        return jsonify({'message': 'Detalle de pedido creado', 'detalle_pedido_id': nuevo_detalle['detalle_pedido_id']})

    def put(self, detalle_id):
        data = request.get_json()
        mongo.db.detalles_pedido.update_one(
            {'detalle_pedido_id': int(detalle_id)},
            {'$set': {
                'pedido_id': data['pedido_id'],
                'producto_id': data['producto_id'],
                'cantidad': data['cantidad']
            }}
        )
        return jsonify({'message': 'Detalle de pedido actualizado'})

    def delete(self, detalle_id):
        mongo.db.detalles_pedido.delete_one({'detalle_pedido_id': int(detalle_id)})
        return jsonify({'message': 'Detalle de pedido eliminado'})

api.add_resource(DetallePedidoResource, '/detalles_pedido', '/detalles_pedido/<int:detalle_id>')

class LoginResource(Resource):
    def post(self):
        data = request.get_json()
        usuario = mongo.db.usuarios.find_one({'email': data['email']})
        if usuario and usuario['password'] == data['password']:
            token = jwt.encode(
                {'id': str(usuario['usuario_id']), 'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=24)},
                app.config['SECRET_KEY'], algorithm="HS256"
            )
            return jsonify({'id': usuario['usuario_id'], 'token': token, 'rol': usuario['rol']})
        return jsonify({'message': 'Credenciales incorrectas'}), 401

api.add_resource(LoginResource, '/login')

class CocinaResource(Resource):
    def get(self):
        pedidos = mongo.db.pedidos.find({'estatus': {'$in': ['pendiente', 'preparando']}})
        return jsonify([{
            'pedido_id': pedido['pedido_id'],
            'mesa_id': pedido['mesa_id'],
            'usuario_id': pedido['usuario_id'],
            'estatus': pedido['estatus'],
            'fecha': pedido['fecha'].isoformat(),
            'detalles': pedido['detalles'],
            'comanda': pedido['comanda']
        } for pedido in pedidos])

    def put(self, pedido_id):
        data = request.get_json()
        try:
            mongo.db.pedidos.update_one(
                {'pedido_id': int(pedido_id)},
                {'$set': {'estatus': data['estatus']}}
            )

            if data['estatus'] == 'listo':
                pedido = mongo.db.pedidos.find_one({'pedido_id': int(pedido_id)})
                if pedido:
                    mesa_id = pedido['mesa_id']
                    mongo.db.mesas.update_one(
                        {'mesa_id': mesa_id},
                        {'$set': {'estatus': 'listo'}}
                    )

            return jsonify({'message': 'Pedido y mesa actualizados'})
        except Exception as e:
            return jsonify({'error': str(e)}), 500

api.add_resource(CocinaResource, '/cocina', '/cocina/<int:pedido_id>')

class MesaEstatusResource(Resource):
    def put(self, mesa_id):
        data = request.get_json()
        mongo.db.mesas.update_one(
            {'mesa_id': int(mesa_id)},
            {'$set': {'estatus': data['estatus']}}
        )
        return jsonify({'message': 'Estatus de la mesa actualizado'})

api.add_resource(MesaEstatusResource, '/mesas/<int:mesa_id>/estatus')

class CobrarPedidoResource(Resource):
    def put(self, pedido_id):
        try:
            mongo.db.pedidos.update_one(
                {'pedido_id': int(pedido_id)},
                {'$set': {'estatus': 'entregado'}}
            )

            pedido = mongo.db.pedidos.find_one({'pedido_id': int(pedido_id)})
            if not pedido:
                return jsonify({'error': 'Pedido no encontrado'}), 404

            mesa_id = pedido['mesa_id']

            mongo.db.mesas.update_one(
                    {'mesa_id': mesa_id},
                    {'$set': {'estatus': 'limpieza'}}
            )    

            return jsonify({'message': 'Pedido cobrado'})
        except Exception as e:
            return jsonify({'error': str(e)}), 500

api.add_resource(CobrarPedidoResource, '/cobrar_pedido/<int:pedido_id>')

@app.route('/usuarios/crear_usuario', methods=['POST'])
def crear_usuario():
    data = request.json
    usuario_id = get_next_sequence('usuario_id')
    nuevo_usuario = {
        'usuario_id': usuario_id,
        'nombre': data['nombre'],
        'email': data['email'],
        'password': data['password'],
        'rol': data['rol']
    }
    mongo.db.usuarios.insert_one(nuevo_usuario)
    return jsonify({'message': 'Usuario creado', 'usuario_id': usuario_id})

@app.route('/usuarios/obtener_usuarios', methods=['GET'])
def obtener_usuarios():
    usuarios = mongo.db.usuarios.find()
    resultado = []
    for usuario in usuarios:
        resultado.append({
            'id': str(usuario['_id']),
            'usuario_id': usuario.get('usuario_id', ''),
            'nombre': usuario['nombre'],
            'email': usuario['email'],
            'rol': usuario['rol']
        })
    return jsonify(resultado)

@app.route('/usuarios/eliminar_usuario/<id>', methods=['DELETE'])
def eliminar_usuario(id):
    try:
        object_id = ObjectId(id)
        result = mongo.db.usuarios.delete_one({'_id': object_id})
        
        if result.deleted_count > 0:
            return jsonify({'message': 'Usuario eliminado'})
        else:
            return jsonify({'message': 'Usuario no encontrado'}), 404
    except Exception as e:
        return jsonify({'message': 'Error al eliminar usuario', 'error': str(e)}), 500

if __name__ == '__main__':
    CORS(app)
    app.run(host='0.0.0.0', port=5002, debug=True)
