"use strict";
const natsModule = require('/usr/common/node_modules/nats');

// load the agent
const newrelic = require('/usr/common/node_modules/newrelic');

// instrument express after the agent has been loaded
newrelic.instrumentLoadedModule(
  'nats',    // the module's name, as a string
  natsModule // the module instance
);

require('./index')