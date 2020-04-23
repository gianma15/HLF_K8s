/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Contract } = require('fabric-contract-api');

class Richiesta extends Contract {

    async init(ctx, reparto) {
        console.info('============= START : Initialize Ledger ===========');
        if (reparto=="tech"){
            var richieste = [
                {
                    docType: 'Richiesta',
                    prodotto: 'PC£MSI£GS70£2QC',
                    descrizione: 'Richiesti£almeno£10',
                    soddisfatta: 'NO',
                },
                {
                    docType: 'Richiesta',
                    prodotto: 'Tablet£2-in-1£Lenovo£MIIX£520',
                    descrizione: 'Richiesti£al£più£3£prezzo£massimo£800',
                    soddisfatta: 'NO',
                },
            ];
        }else if (reparto=="garden"){
            var richieste = [
                {
                    docType: 'Richiesta',
                    prodotto: 'Concime£oligominerale£granulare£15-15-15',
                    descrizione: 'Richiesti£almeno£400Kg',
                    soddisfatta: 'NO',
                },
            ];
        }

        for (let i = 0; i < richieste.length; i++) {
            await ctx.stub.putState('Richiesta' + i, Buffer.from(JSON.stringify(richieste[i])));
            console.info('Added <--> ', richieste[i]);
        }
        console.info('============= END : Initialize Ledger ===========');
    }

    async queryRichiesta(ctx, RichiestaID) {
        const RichiestaAsBytes = await ctx.stub.getState(RichiestaID); // get the Richiesta from chaincode state
        if (!RichiestaAsBytes || RichiestaAsBytes.length === 0) {
            throw new Error(`${RichiestaID} does not exist`);
        }
        console.log(RichiestaAsBytes.toString());
        return RichiestaAsBytes.toString();
    }

    async createRichiesta(ctx, RichiestaID, prodotto, descrizione, soddisfatta) {
        console.info('============= START : Create Richiesta ===========');

        const Richiesta = {
            docType: 'Richiesta',
            prodotto,
            descrizione,
            soddisfatta,
        };

        await ctx.stub.putState(RichiestaID, Buffer.from(JSON.stringify(Richiesta)));
        console.info('============= END : Create Richiesta ===========');
    }

    async deleteRichiesta(ctx, RichiestaID){
        console.info('============= START : Delete Richiesta ===========');
        await ctx.stub.deleteState(RichiestaID);
        console.info('============= END : Delete Richiesta ===========');
    }

    async soddisfaRichiesta(ctx, RichiestaID, OffertaID) {
        console.info('============= START : soddisfaRichiesta ===========');

        const RichiestaAsBytes = await ctx.stub.getState(RichiestaID); // get the Richiesta from chaincode state
        if (!RichiestaAsBytes || RichiestaAsBytes.length === 0) {
            throw new Error(`${RichiestaID} does not exist`);
        }
        const Richiesta = JSON.parse(RichiestaAsBytes.toString());
        Richiesta.soddisfatta = 'SI -> '+OffertaID;

        await ctx.stub.putState(RichiestaID, Buffer.from(JSON.stringify(Richiesta)));
        console.info('============= END : soddisfaRichiesta ===========');
    }

    async queryAllRichiesta(ctx) {
        
        
        const allResults = [];
        for await (const {key, value} of ctx.stub.getStateByRange('', '')) {
            const strValue = Buffer.from(value).toString('utf8');
            let record;
            try {
                record = JSON.parse(strValue);
            } catch (err) {
                console.log(err);
                record = strValue;
            }
            allResults.push({ Key: key, Record: record });
        }
        console.info(allResults);
        return JSON.stringify(allResults);
    }

    async queryAllRichiestaSoddisfatte(ctx) {
        
        
        const allResults = [];
        for await (const {key, value} of ctx.stub.getStateByRange('','')) {
            const strValue = Buffer.from(value).toString('utf8');
            let record;
            try {
                record = JSON.parse(strValue);
            } catch (err) {
                console.log(err);
                record = strValue;
            }
            if (record.soddisfatta.slice(0,2) == 'SI') {
                allResults.push({ Key: key, Record: record });
            }
        }
        console.info(allResults);
        return JSON.stringify(allResults);
    }

    async queryAllRichiestaInsoddisfatte(ctx) {
        
        
        const allResults = [];
        for await (const {key, value} of ctx.stub.getStateByRange('','')) {
            const strValue = Buffer.from(value).toString('utf8');
            let record;
            try {
                record = JSON.parse(strValue);
            } catch (err) {
                console.log(err);
                record = strValue;
            }
            if (record.soddisfatta == 'NO') {
                allResults.push({ Key: key, Record: record });
            }
        }
        console.info(allResults);
        return JSON.stringify(allResults);
    }

}

module.exports = Richiesta;
