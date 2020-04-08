/*
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Contract } = require('fabric-contract-api');

class Offerta extends Contract {

    async proponiOfferta(ctx) {
        //, OffertaID, RichiestaID, quantita, prezzo, fornitore
        console.info('============= START : Proponi Offerta ===========');
        // let transMap = ctx.stub.getTransient();
        // console.info(transMap.get('offerta'));
        // let b=Buffer.from(transMap.get('offerta'));
        // console.info(b.toString('utf-8'));
        var jsonMap = JSON.parse(Buffer.from(ctx.stub.getTransient().get('offerta')).toString('utf-8')); //OffertaID, RichiestaID, quantita, prezzo, fornitore
        const Offerta = {
            docType: 'Offerta',
            RichiestaID: jsonMap["RichiestaID"],
            quantita: jsonMap["quantita"],
            prezzo: jsonMap["prezzo"],
            fornitore: jsonMap["fornitore"],
            accettata: "sospesa",
        };

        if (Offerta.fornitore == "Forn1") {
            await ctx.stub.putPrivateData("collectionOfferteForn1", jsonMap["OffertaID"], Buffer.from(JSON.stringify(Offerta)));
        } else if (Offerta.fornitore == "Forn2") {
            await ctx.stub.putPrivateData("collectionOfferteForn2", jsonMap["OffertaID"], Buffer.from(JSON.stringify(Offerta)));
        }
        console.info('============= END : Proponi Offerta ===========');
    }

    async accettaOfferta(ctx, OffertaID, fornitore) {
        console.info('============= START : accettaOfferta ===========');

        if (fornitore == "Forn1") {
            var OffertaAsBytes = await ctx.stub.getPrivateData("collectionOfferteForn1", OffertaID); // get the Offerta from chaincode state
        } else if (fornitore == "Forn2") {
            var OffertaAsBytes = await ctx.stub.getPrivateData("collectionOfferteForn2", OffertaID);
        }
        if (!OffertaAsBytes || OffertaAsBytes.length === 0) {
            throw new Error(`${OffertaID} does not exist`);
        }
        const Offerta = JSON.parse(OffertaAsBytes.toString());
        Offerta.accettata = "SI";
        if (fornitore == "Forn1") {
            await ctx.stub.putPrivateData("collectionOfferteForn1", OffertaID, Buffer.from(JSON.stringify(Offerta)));
        } else if (fornitore == "Forn2") {
            await ctx.stub.putPrivateData("collectionOfferteForn2", OffertaID, Buffer.from(JSON.stringify(Offerta)));
        }
        console.info('============= END : accettaOfferta ===========');
        this.rifiutaAllOthers(ctx, OffertaID, Offerta.RichiestaID, fornitore);
    }

    async rifiutaOfferta(ctx, OffertaID, fornitore) {
        console.info('============= START : rifiutaOfferta ===========');
        if (fornitore == "Forn1") {
            var OffertaAsBytes = await ctx.stub.getPrivateData("collectionOfferteForn1", OffertaID); // get the Offerta from chaincode state
        } else if (fornitore == "Forn2") {
            var OffertaAsBytes = await ctx.stub.getPrivateData("collectionOfferteForn2", OffertaID);
        }
        if (!OffertaAsBytes || OffertaAsBytes.length === 0) {
            throw new Error(`${OffertaID} does not exist`);
        }
        const Offerta = JSON.parse(OffertaAsBytes.toString());
        Offerta.accettata = "NO";
        if (fornitore == "Forn1") {
            // var OffertaAsBytes = await ctx.stub.deletePrivateData("collectionOfferteForn1", OffertaID); // get the Offerta from chaincode state
            await ctx.stub.putPrivateData("collectionOfferteForn1", OffertaID, Buffer.from(JSON.stringify(Offerta)));
        } else if (fornitore == "Forn2") {
            // var OffertaAsBytes = await ctx.stub.deletePrivateData("collectionOfferteForn2", OffertaID);
            await ctx.stub.putPrivateData("collectionOfferteForn2", OffertaID, Buffer.from(JSON.stringify(Offerta)));
        }
        console.info('============= END : rifiutaOfferta ===========');
    }

    async rifiutaAllOthers(ctx, OffertaID, RichiestaID, fornitore) {
        console.info('============= START : rifiutaAllOthers ===========');
        // const startKey = 'Offerta0';
        // const endKey = 'Offerta999';
        if (fornitore == "Forn1") {
            var range = ctx.stub.getPrivateDataByRange("collectionOfferteForn1", startKey, endKey);
            //var range = ctx.stub.getPrivateDataByRange("collectionOfferteForn1",'','');
        } else if (fornitore == "Forn2") {
            var range = ctx.stub.getPrivateDataByRange("collectionOfferteForn2", startKey, endKey);
            //var range = ctx.stub.getPrivateDataByRange("collectionOfferteForn2",'','');
        }
        for await (const { key, value } of range) {
            const strValue = Buffer.from(value).toString('utf8');
            let record;
            try {
                record = JSON.parse(strValue);
            } catch (err) {
                console.log(err);
                record = strValue;
            }
            if (record.OffertaID != OffertaID && record.RichiestaID == RichiestaID) {
                this.rifiutaOfferta(ctx, OffertaID, fornitore);
            }
        }
        console.info('============= END : rifiutaAllOthers ===========');
    }

    async queryOfferta(ctx, OffertaID, fornitore) {
        // let forn=ctx.stub.invokeChaincode(richiesta,["queryRichiesta",RichiestaID]);
        if (fornitore == "Forn1") {
            var OffertaAsBytes = await ctx.stub.getPrivateData("collectionOfferteForn1", OffertaID); // get the Offerta from chaincode state
        } else if (fornitore == "Forn2") {
            var OffertaAsBytes = await ctx.stub.getPrivateData("collectionOfferteForn2", OffertaID);
        }
        if (!OffertaAsBytes || OffertaAsBytes.length === 0) {
            throw new Error(`${OffertaID} does not exist`);
        }
        console.log(OffertaAsBytes.toString());
        return OffertaAsBytes.toString();
    }

    async queryAllOfferta(ctx, RichiestaID, fornitore) {
        const startKey = 'Offerta0';
        const endKey = 'Offerta999';
        const allResults = [];
        if (fornitore == "Forn1") {
            var range = ctx.stub.getPrivateDataByRange("collectionOfferteForn1", startKey, endKey);
        } else if (fornitore == "Forn2") {
            var range = ctx.stub.getPrivateDataByRange("collectionOfferteForn2", startKey, endKey);
        }
        for await (const { key, value } of range) {
            const strValue = Buffer.from(value).toString('utf8');
            let record;
            try {
                record = JSON.parse(strValue);
            } catch (err) {
                console.log(err);
                record = strValue;
            }
            if (record.RichiestaID == RichiestaID) {
                allResults.push({ Key: key, Record: record });
            }
        }
        console.info(allResults);
        return JSON.stringify(allResults);
    }

}

module.exports = Offerta;
