module tienda::suplementos {
    use sui::object;
    use sui::transfer;
    use sui::tx_context;
    use sui::vec_map::{Self, VecMap};
    use std::string::String;

    // Estructura principal Tienda, con key para almacenarse globalmente
    public struct Tienda has key {
        id: UID,
        nombre: String,
        contacto: String,
        suplementos: VecMap<u8, Suplemento>,  // Mapa de ID a Suplemento
    }

    // Estructura Suplemento con los campos requeridos
    public struct Suplemento has store, drop, copy {
        nombre: String,
        categoria: String,
        precio: u64,
        disponible: bool,
    }

    // Códigos de error para manejo simple
    const ID_YA_EXISTE: u64 = 1;
    const ID_NO_EXISTE: u64 = 2;

    // Función para crear la tienda con nombre y contacto
    public fun crear_tienda(nombre: String, contacto: String, ctx: &mut TxContext) {
        let tienda = Tienda {
            id: object::new(ctx),
            nombre,
            contacto,
            suplementos: vec_map::empty(),
        };
        transfer::transfer(tienda, tx_context::sender(ctx));
    }

    // Función para registrar un suplemento nuevo en la tienda
    public fun registrar_suplemento(
        tienda: &mut Tienda, id: u8, nombre: String, categoria: String, precio: u64, disponible: bool
    ) {
        // Verificamos que el suplemento con el id no exista ya
        assert!(!tienda.suplementos.contains(&id), ID_YA_EXISTE);

        let suplemento = Suplemento {
            nombre,
            categoria,
            precio,
            disponible,
        };
        tienda.suplementos.insert(id, suplemento);
    }

    // Función para actualizar la disponibilidad de un suplemento
    public fun actualizar_disponibilidad(tienda: &mut Tienda, id: u8, disponible: bool) {
        assert!(tienda.suplementos.contains(&id), ID_NO_EXISTE);
        let suplemento = tienda.suplementos.get_mut(&id);
        suplemento.disponible = disponible;
    }

    // Función para consultar la información de un suplemento por ID
    // Función para consultar la información de un suplemento por ID
    public fun obtener_info_suplemento(tienda: &Tienda, id: u8): Suplemento {
    assert!(tienda.suplementos.contains(&id), ID_NO_EXISTE);
    let suplemento_ref = tienda.suplementos.get(&id);
    let suplemento = *suplemento_ref; // copia el valor
    suplemento
}

    // Función para saber cuántos suplementos hay registrados
    public fun contar_suplementos(tienda: &Tienda): u64 {
        vec_map::length(&tienda.suplementos) as u64
    }

    // Función para eliminar un suplemento por su ID
    public fun eliminar_suplemento(tienda: &mut Tienda, id: u8) {
        assert!(tienda.suplementos.contains(&id), ID_NO_EXISTE);
        tienda.suplementos.remove(&id);
    }

    // Función para eliminar la tienda (objeto completo)
    public fun eliminar_tienda(tienda: Tienda) {
        let Tienda { id, nombre: _, contacto: _, suplementos: _ } = tienda;
        id.delete();
    }
}