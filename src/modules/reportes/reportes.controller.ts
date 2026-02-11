
import { Request, Response } from 'express';
import { reportesService } from './reportes.service';

export class ReportesController {
    async getKpis(_req: Request, res: Response) {
        try {
            const kpis = await reportesService.getKpis();
            res.json(kpis);
        } catch (error) {
            console.error('Error al obtener KPIs:', error);
            res.status(500).json({ error: 'Error al obtener KPIs del sistema' });
        }
    }

    async getTopMinas(_req: Request, res: Response) {
        try {
            const minas = await reportesService.getTopMinas();
            res.json(minas);
        } catch (error) {
            console.error('Error al obtener Top Minas:', error);
            res.status(500).json({ error: 'Error al obtener ranking de minas' });
        }
    }

    async getTendencia(_req: Request, res: Response) {
        try {
            const tendencia = await reportesService.getTendenciaMensual();
            res.json(tendencia);
        } catch (error) {
            console.error('Error al obtener tendencia:', error);
            res.status(500).json({ error: 'Error al obtener tendencia mensual' });
        }
    }
}

export const reportesController = new ReportesController();
