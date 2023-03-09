const NATS = require("nats");
const zlib = require("zlib");

// node /usr/local/common/guardian-healthcheck.js
(async () => {
  const serviceName =
    process.env.HEALTHCHECK_CHANNEL_NAME || process.env.SERVICE_CHANNEL;
  console.log("Running healthcheck for service: ", serviceName);
  let alive = true;
  const nats = await NATS.connect({
    name: `${process.env.SERVICE_CHANNEL}-healthcheck`,
    servers: [process.env.MQ_ADDRESS],
  });

  try {
    const c = NATS.JSONCodec();
    const sc = NATS.StringCodec();

    console.log("Test NATS connection");
    await nats.publish(
      "guardian.healthcheck",
      c.encode({ message: "guardian.healthcheck" })
    );
    console.log("Verify NATS connection : ", serviceName + ".GET_STATUS");

    console.log("start", new Date().toISOString());
    const head = NATS.headers();
    const messageId = new Date().toISOString();
    head.append("messageId", messageId);
    let healthcheckRes = null;

    const fn = async (_sub) => {
      for await (const m of _sub) {
        if (!m.headers) {
          console.error("No headers");
          return;
        }
        const messageIdRes = m.headers.get("messageId");
        if (messageId === messageIdRes) {
          healthcheckRes = JSON.parse(NATS.StringCodec().decode(m.data));
        }
      }
    };
    const enableServiceCheck = false;
    if (enableServiceCheck) {
      fn(
        nats.subscribe("response-message", {
          queue: `${process.env.SERVICE_CHANNEL}-healthcheck`,
        })
      ).then();

      await nats.request(serviceName + ".GET_STATUS", sc.encode("{}"), {
        timeout: 30000,
        headers: head,
      });

      await new Promise((resolve, reject) => {
        setTimeout(() => {
          if (healthcheckRes && healthcheckRes.body === "READY") {
            console.log("Service is ready");
          } else {
            reject(new Error("Healthcheck failed"));
          }
          resolve();
        }, 1000);
      });
    }

    // await nats.request('logger-service.GET_LOGS', sc.encode("{}"));
  } catch (e) {
    alive = false;
    console.error("Error:", e);
  } finally {
    await nats.close();
  }

  if (!alive) {
    process.exit(1);
  }
})();
