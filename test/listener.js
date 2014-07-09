var corredor = require('corredor-js'),
    mozrunner = require('mozilla-runner');

var worker = new corredor.ExclusivePair();
worker.bind('ipc:///tmp/marionette_socket_host_worker');

var _proc = null;
function onStart(data) {
  function done(err, proc) {
    if (err) console.log(err);
    _proc = proc;
    worker.send({action: 'ready_start'});
  }

  function run() {
    mozrunner.run(
      data.target,
      data.options,
      done
    );
  }

  run();
};

function onStop(data) {
  if (_proc) {
    _proc.on('exit', done);
    _proc.kill();
    _proc = null;
  }

  function done() {
    worker.send({action: 'ready_stop'});
  }
};

worker.registerAction('start_runner', onStart);
worker.registerAction('stop_runner', onStop);

process.on('exit', function() {
  worker.close();
  if (_proc) {
    _proc.kill();
  }
});
