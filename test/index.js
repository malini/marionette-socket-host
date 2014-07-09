suite('host', function() {
  var Marionette = require('marionette-client'),
      Host = require('../'),
      mozprofile = require('mozilla-profile-builder'),
      emptyPort = require('empty-port'),
      net = require('net'),
      fs = require('fs');
  var fork = require('child_process').fork;

  function connect(port, callback) {
    function done() {
      callback();
    }
    var Tcp = Marionette.Drivers.Tcp;

    // the intent is to verify that the marionette connection can/cannot work.
    var m = new Tcp({ port: port, tries: 5 })
    m.connect(done);
  }

  var subject;
  setup(function() {
    subject = new Host();
  });

  var port;
  setup(function(done) {
    emptyPort({ startPort: 60000 }, function(err, _port) {
      port = _port;
      done(err);
    });
  });

  var profile;
  setup(function(done) {
    var options = {
      profile: ['gaia', __dirname + '/../b2g'],
      prefs: {
        'marionette.defaultPrefs.enabled': true,
        'marionette.defaultPrefs.port': port
      }
    };

    mozprofile.create(options, function(err, _profile) {
      profile = _profile;
      done(err);
    });
  });

  teardown(function(done) {
    profile.destroy(done);
  });

  var child;
  setup(function(done) {
    child = fork('test/listener.js');
    done();
  });

  teardown(function(done) {
    child.on('close', function(code, signal) {
      done();
    });
    child.kill();
  });

  test('.options', function() {
    var subject = new Host({ xxx: true });
    assert.equal(subject.options.xxx, true);
  });

  test('Host.metadata', function() {
    assert.equal(Host.metadata.host, 'socket');
  });

  suite('#start', function() {
    setup(function(done) {
      subject.start(profile.path, {}, done);
    });

    test('can connect after start', function(done) {
      connect(port, done);
    });

    teardown(function(done) {
      subject.stop(done);
    });
  });

  suite('#stop', function() {
    setup(function(done) {
      subject.start(profile.path, done);
    });

    setup(function(done) {
      subject.stop(done);
    });

    test('after closing process', function(done) {
      var socket = net.connect(port);
      socket.on('error', function(err) {
        assert.equal(err.code, 'ECONNREFUSED');
        done();
      });
    });
  });
});
