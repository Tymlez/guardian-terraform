const NATS = require('nats');
const zlib = require('zlib');

// node /usr/common/tymlez-healthcheck.js
(async () => {
  const serviceName = process.env.HEALCHECK_CHANNEL_NAME || process.env.SERVICE_CHANNEL;
  console.log("Running healthcheck for service: ", serviceName);
  let alive = true;
  const nats = await NATS.connect({
    name: `${process.env.SERVICE_CHANNEL}-healthcheck`,
    servers: [process.env.MQ_ADDRESS]
  });

  try {
    const c = NATS.JSONCodec();
    const sc = NATS.StringCodec();

    console.log("Test NATS connection");
    await nats.publish('TYMLEZ.healthcheck', c.encode({ message: 'TYMLEZ.healthcheck' }));
    console.log("Verify NATS connection : ", serviceName + '.GET_STATUS');
    console.log("start", new Date().toISOString())
    const msg = await nats.request(serviceName + '.GET_STATUS', sc.encode("{}"), { timeout: 30000 });
    const unpackedString = zlib.inflateSync(Buffer.from(NATS.StringCodec().decode(msg.data), 'binary')).toString();

    const res = JSON.parse(unpackedString);
    console.log("Nats response: ", res);

    console.log("End", new Date().toISOString())

    if (res.body !== 'READY') {
      throw new Error("Service is not ready");
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
}
)();