// functions/index.js

const {onSchedule} = require("firebase-functions/v2/scheduler");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const logger = require("firebase-functions/logger");
const axios = require("axios");

// Inicialize o Firebase Admin SDK para que a função possa acessar o Firestore e o FCM
initializeApp();

// Função agendada para rodar a cada 60 minutos.
// Você pode mudar o intervalo aqui, se desejar.
exports.checkAcledForNewEvents = onSchedule("every 60 minutes", async (event) => {
  logger.log("Checking ACLED API for new events...");

  // --- CONFIGURAÇÃO DA API ACLED ---
  // IMPORTANTE: Armazene suas credenciais de forma segura!
  // Use "firebase functions:config:set acled.key=SUA_CHAVE acled.user=SEU_EMAIL"
  // E acesse com functions.config().acled.key
  const ACLED_API_KEY = "***REMOVED***"; // SUBSTITUA PELA SUA CHAVE
  const ACLED_API_USER = "mylena.nunes@estudante.ifro.edu.br"; // SUBSTITUA PELO SEU EMAIL

  // Calcula a data de uma hora atrás no formato YYYY-MM-DD
  const oneHourAgo = new Date();
  oneHourAgo.setHours(oneHourAgo.getHours() - 1);
  const dateFilter = oneHourAgo.toISOString().split("T")[0];

  const acledUrl = `https://api.acleddata.com/acled/read?key=${ACLED_API_KEY}&email=${ACLED_API_USER}&event_date=${dateFilter}&limit=500&order_by=event_date`;

  try {
    const response = await axios.get(acledUrl);
    const events = response.data.data;

    if (!events || events.length === 0) {
      logger.log("No new events found in the last hour.");
      return null;
    }

    // Obtenha uma referência ao banco de dados Firestore
    const db = getFirestore();
    const processedEventsRef = db.collection("processed_events");

    // Para cada evento encontrado, verifique se já foi processado
    for (const ev of events) {
      const eventId = ev.data_id.toString();
      const doc = await processedEventsRef.doc(eventId).get();

      if (doc.exists) {
        // Se o documento já existe, pule para o próximo evento
        logger.log(`Event ${eventId} already processed. Skipping.`);
        continue;
      }

      // Se o evento é novo, envie a notificação
      logger.log(`New event found: ${eventId}. Sending notification...`);

      // Crie um nome de tópico limpo, igual ao do app
      const countryTopic = ev.country.toLowerCase().replace(/[^a-z0-9_]/g, "");

      const message = {
        notification: {
          title: `New Conflict Event in ${ev.country}`,
          body: `${ev.event_type} reported in ${ev.admin1}.`,
        },
        topic: countryTopic,
      };

      // Envie a mensagem para o tópico FCM
      await getMessaging().send(message);
      logger.log("Notification sent successfully to topic:", countryTopic);

      // Salve o ID do evento no Firestore para não processá-lo novamente
      await processedEventsRef.doc(eventId).set({
        processed_at: new Date(),
      });
    }

    return logger.log("Function finished successfully.");
  } catch (error) {
    logger.error("Error fetching or processing ACLED data:", error);
    return null;
  }
});