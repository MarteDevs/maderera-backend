import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
    console.log('Seeding database...');

    // 1. Clasificacion y Medida
    const clasif = await prisma.clasificaciones.upsert({
        where: { nombre: 'Madera General' },
        update: {},
        create: { nombre: 'Madera General', descripcion: 'Clasificación default' }
    });

    const medida = await prisma.medidas.upsert({
        where: { descripcion: 'Metro Cubico' },
        update: {},
        create: { descripcion: 'Metro Cubico', largo_mts: 1, diametro_min_cm: 10, diametro_max_cm: 20 }
    });

    // 2. Producto
    const producto = await prisma.productos.create({
        data: {
            nombre: 'Eucalipto Test',
            id_medida: medida.id_medida,
            id_clasificacion: clasif.id_clasificacion,
            stock_actual: 0
        }
    }); // Create new one to avoid unique constraint if logic differs (nombre allows dups? no unique on nombre in schema? Check schema: @index([nombre]), no unique. OK to create mult, but better connect if exists. )

    // Better: upsert product if unique name? 
    // Schema: nombre is NOT unique. So let's check first using findFirst.
    const existProd = await prisma.productos.findFirst({ where: { nombre: 'Eucalipto Test' } });
    const id_producto = existProd ? existProd.id_producto : (await prisma.productos.create({
        data: {
            nombre: 'Eucalipto Test',
            id_medida: medida.id_medida,
            id_clasificacion: clasif.id_clasificacion,
            stock_actual: 0
        }
    })).id_producto;


    // 3. Proveedor
    const proveedor = await prisma.proveedores.upsert({
        where: { nombre: 'Proveedor Test' },
        update: {},
        create: { nombre: 'Proveedor Test', ruc: '20123456789' }
    });

    // 4. Mina
    const mina = await prisma.minas.upsert({
        where: { nombre: 'Mina Test' },
        update: {},
        create: { nombre: 'Mina Test' }
    });

    // 5. Supervisor
    const supervisor = await prisma.supervisores.upsert({
        where: { nombre: 'Supervisor Test' },
        update: {},
        create: { nombre: 'Supervisor Test', email: 'sup@test.com' }
    });

    // 6. Usuario Admin
    const hash = await bcrypt.hash('password', 10);
    const user = await prisma.usuarios.upsert({
        where: { username: 'admin' },
        update: { password_hash: hash }, // Update pwd to be sure
        create: {
            username: 'admin',
            password_hash: hash,
            nombre_completo: 'Admin User',
            rol: 'ADMIN',
            id_supervisor: supervisor.id_supervisor
        }
    });

    // 7. Precio (Producto-Proveedor)
    await prisma.producto_proveedores.upsert({
        where: {
            id_proveedor_id_producto: {
                id_proveedor: proveedor.id_proveedor,
                id_producto: id_producto
            }
        },
        update: {},
        create: {
            id_proveedor: proveedor.id_proveedor,
            id_producto: id_producto,
            precio_compra_sugerido: 50.00
        }
    });

    console.log('Seed completed!');
    console.log({
        user: 'admin',
        pass: 'password',
        ids: {
            producto: id_producto,
            proveedor: proveedor.id_proveedor,
            mina: mina.id_mina,
            supervisor: supervisor.id_supervisor
        }
    });
}

main()
    .then(async () => {
        await prisma.$disconnect();
    })
    .catch(async (e) => {
        console.error(e);
        await prisma.$disconnect();
        process.exit(1);
    });
