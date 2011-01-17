var PrimProc = types.PrimProc;

var BLOBS = ((function () {

    var DEBUG = true;

    function debug(str) {
        if(DEBUG) { console.log(str); }
    }

    function hashRef(o, f) /*: {} * Str -> Bool */ {
        return typeof f === 'string' && 
          Object.prototype.hasOwnProperty.call(o, f) && 
          o[f];
    }

    // A Blob holds some state, a dictionary of handlers, and
    // a map of event names to lists of blobs
    function Blob(state, handlers) 
    /*: [Blob] a * Array<Handler> -> Blob */ 
    {
        this.state = state;
        this.handlers = {};
        for(var i = 0; i < handlers.length; i++) {
            this.handlers[handlers[i].name] = handlers[i].handler;
        }
        this.listeners = {}; // No blobs initially listen
    }

    function defaultToString()
    /*: [Blob] -> Str */  {
        return "<blob>:" + String(this.state) + String(this.handlers);
    }

    Blob.prototype = {

        addListener: function(handlerName, otherBlob) 
        /* [Blob<a>] Str * Blob<b> -> Blob<a> */ {
            var currentListeners = 
                hashRef(this.listeners, handlerName) || [];
            console.log("Adding: " + otherBlob);
            currentListeners.push(otherBlob);
            this.listeners[handlerName] = currentListeners;
            return this;
        },

        removeListener: function(handlerName, otherBlob) 
        /* [Blob<a>] Str * Blob<b> -> Blob<a> */ {
            var currentListeners = 
                hashRef(this.listeners, handlerName) || [];
            var newListeners = [];
            for(var i = 0; i < currentListeners.length; i++) {
                if(currentListeners[i] !== otherBlob) {
                    newListeners[i] = currentListeners[i];
                }
            }
            if(currentListeners.length === newListeners.length) {
                console.log("WARNING (blob.js): Removing non-existent listener " + 
                            handlerName);
            }
            this.listeners[handlerName] = newListeners;
            return this;
        },

        fire: function(handlerName, handlerArg) {
            console.log("Firing " + handlerName);
            console.log("Listeners: " + this.listeners);
            var listens = hashRef(this.listeners, String(handlerName));
            if(String(handlerName) === 'init') {
                throw new Error("Can't send init!");
            }
            if(!listens)  { 
                console.log("Firing " + handlerName + " with no listeners.");
                return;
            }
            // TODO --- ordering?
            helpers.forEachK(listens,
                             function(listener, k2) {
                                 // Enqueue on the JS engine's event queue to get
                                 // some sense of fairness (setTimeout does this).
                                 // May want to explicitly store the message queue
                                 // at some point.
                                 setTimeout(function() {
                                     listener.receive(handlerName, handlerArg, k2);
                                 }, 0);
                             },
                             function (e) { 
                                 console.log("Error in fire " +  e); 
                                 throw e;
                             },
                             function () {});
        },

        receive: function(handlerName, handlerArg) 
        /*: [Blob<a>] Str * b ->  a */ {
            var handler = hashRef(this.handlers, String(handlerName));
            var newState;
            console.log("Blob receiving: " + handlerName);
            if(handler) {
                // Just one argument other than the state for now
                handler(this, handlerArg);
            }
            else { 
                throw new Error("Blob isn't registered for " + 
                                handlerName + ", but received it.");
            }
        },

        toWrittenString: defaultToString,
        toString: defaultToString,
        toDisplayedString: defaultToString,
    }

    return {
        Blob: Blob,
        blobSignature: ['addListener', 'removeListener', 'receive', 'fire',
                        'listeners', 'handlers', 'state'],
    }

})());


function Register(otherBlob, handlerName) 
/*: Blob * Str -> Register */ {
    this.otherBlob = otherBlob;
    this.handlerName = handlerName;
}

Register.prototype = {
    register: function(thisBlob) {
        this.otherBlob.addListener(this.handlerName, thisBlob);
    }
}

function Introduction(blob) {
    this.blob = blob;
}

Introduction.prototype = {
    introduce: function() {
        this.blob.receive('init');
    }
}

function Signal(handlerName, handlerArg) {
    this.handlerName = handlerName;
    this.handlerArg = handlerArg;
}

Signal.prototype = {
    send: function(blob) {
        blob.fire(this.handlerName, this.handlerArg);
    }
}

function Nothing() {
}

Nothing.prototype = {
    some: function() { throw new Error("Getting some of None"); },
    isSome: function() { return false; },
    isNothing: function() { return true; }
}

function Some(value) {
    this.value = value;
}

Some.prototype = {
    some: function() { return this.value; },
    isSome: function() { return true; },
    isNothing: function() { return false; }
}

// Represents the value a handler evaluates to --- definitely a value for the
// blob, and possibly some signals to send out, and some (de)registrations to 
// make with other blobs.
/*: type HandlerResult = 
    {newValue: a,
     maybeSignals: Maybe<Array<Signal>>,
     maybeRegisters: Maybe<Array<Registers>>,
     maybeDeregisters: Maybe<Array<Deregisters>>,
     #proto: {getNewValue: [HandlerResult] -> a,
              getSignals: [HandlerResult] -> Array<Signal>,
              hasSignals: [HandlerResult] -> Bool,
              getRegisters: [HandlerResult] -> Array<Register>,
              hasRegisters: [HandlerResult] -> Bool,
              getIntroductions: [HandlerResult] -> Array<Init>,
              hasIntroductions: [HandlerResult] -> Array<Init>,
              getDeregisters: [HandlerResult] -> Array<Deregister>,
              hasDeregisters: [HandlerResult] -> Bool}
} */
function HandlerResult(newValue, 
                       maybeSignals, 
                       maybeRegisters, 
                       maybeIntroductions, 
                       maybeDeregisters) 
/*:  constructor
     a 
   * Array<Signal> 
   * Array<Register> 
   * Array<Deregister> 
  -> HandlerResult */ {
      this.newValue = newValue;
      this.maybeSignals = maybeSignals;
      this.maybeRegisters = maybeRegisters;
      this.maybeIntroductions = maybeIntroductions;
      this.maybeDeregisters = maybeDeregisters;
}

function isHandlerResult(v) { return v instanceof HandlerResult; }

HandlerResult.prototype = {
    getNewValue: function() { return this.newValue; },

    getRegisters: function() {
        if(this.maybeRegisters.isSome()) { return this.maybeRegisters.some(); }
        else { throw new Error("Getting registers when there are none."); }
    },
    hasRegisters: function() { return this.maybeRegisters.isSome(); },

    getDeregisters: function() {
        if(this.maybeDeregisters.isSome()) { return this.maybeDeregisters.some(); }
        else { throw new Error("Getting deregisters when there are none."); }
    },
    hasDeregisters: function() { return this.maybeDeregisters.isSome(); },

    getSignals: function() {
        if(this.maybeSignals.isSome()) { return this.maybeSignals.some(); }
        else { throw new Error("Getting signals when there are none."); }
    },
    hasSignals: function() { return this.maybeSignals.isSome(); },

    getIntroductions: function() {
        if(this.maybeIntroductions.isSome()) { return this.maybeIntroductions.some(); }
        else { throw new Error("Getting inits when there are none."); }
    },
    hasIntroductions: function() { return this.maybeIntroductions.isSome(); },

}

EXPORTS['handler-complete'] =
    new types.CasePrimitive(
        'handler-complete',
        [new PrimProc('handler-complete',
                      1,
                      false, false,
                      function(newValue) {
                          return new HandlerResult(
                              newValue,       // Blob value
                              new Nothing(),  // Signals
                              new Nothing(),  // Registers
                              new Nothing(),  // Introductions
                              new Nothing()); // Deregs
                      }),
         new PrimProc('handler-complete',
                      2,
                      false, false,
                      function(newValue, signals) {
                          return new HandlerResult(
                              newValue,
                              new Some(helpers.schemeListToArray(signals)),
                              new Nothing(),
                              new Nothing(),
                              new Nothing());
                      }),
         new PrimProc('handler-complete',
                      3, false, false,
                      function(newValue, signals, registers) {
                          return new HandlerResult(
                              newValue,
                              new Some(helpers.schemeListToArray(signals)),
                              new Some(helpers.schemeListToArray(registers)),
                              new Nothing(),
                              new Nothing());
                      }),
         new PrimProc('handler-complete',
                      4, false, false,
                      function(newValue, signals, registers, introductions) {
                          return new HandlerResult(
                              newValue,
                              new Some(helpers.schemeListToArray(signals)),
                              new Some(helpers.schemeListToArray(registers)),
                              new Some(helpers.schemeListToArray(introductions)),
                              new Nothing());
                      })]);

EXPORTS['register'] =
    new types.PrimProc('register',
                       2, false, false,
                       function(otherBlob, handlerName) {
                           return new Register(otherBlob, handlerName);
                       });

function makeBlobHandler(handlerFun, caller) {
    return function(blob, handlerArg) {
        caller(handlerFun, [blob.state, handlerArg],
               function (handlerResult) {
                   var signals, registers, introductions;
                   if(!(isHandlerResult(handlerResult))) {
                       throw new Error("Needed a handler result, got " + 
                                       String(handlerResult));
                   }
                   // The blob always gets its new value first (so this will be 
                   // reflected in any cycles that come back around
                   blob.state = handlerResult.getNewValue();

                   if(handlerResult.hasRegisters()) {
                       registers = handlerResult.getRegisters();
                       registers.forEach(function(reg) {
                           // The Registration knows what blob to register
                           // *for*, we pass its register method the blob to
                           // register *to* (this one).
                           reg.register(blob);
                       });
                   }
                   if(handlerResult.hasIntroductions()) {
                       introductions = handlerResult.getIntroductions();
                       introductions.forEach(function(intro) {
                           intro.introduce();
                       });
                   }

                   // Ordering?
                   if(handlerResult.hasSignals()) {
                       signals = handlerResult.getSignals();
                       signals.forEach(function(sig) {
                           sig.send(blob);
                       });
                   }
                   return blob.state;
               },
               function(e) {
                   throw new Error("Error in evaluating blob handler: " + e + ", " + e.message);
               });
    };
}

EXPORTS['blob-impl'] =
    new types.PrimProc('blob-impl',
                 1, true, false,
                 function (blobValue, blobHandlers) {
                     return types.internalPause(function(caller, restarter, onFail) {
                         var wrappedHandlers = [];
                         console.log("Making a blob: " + blobValue);
                         console.log(blobValue);
                         console.log(blobHandlers);
                         for(var i = 0; i < blobHandlers.length;  i++) {
                             wrappedHandlers[i] = {};
                             wrappedHandlers[i].handler = 
                                 makeBlobHandler(blobHandlers[i].handler, caller);
                             wrappedHandlers[i].name = blobHandlers[i].name;
                         }
                         var the_blob = new BLOBS.Blob(blobValue, wrappedHandlers);
                         return restarter(the_blob);
                     });
                 });

EXPORTS['blob-impl2'] = 
    new types.PrimProc('blob-impl2',
                 1, false, true,
                 function (blobValue) {
                     return new BLOBS.Blob(blobValue, []);
                 });

EXPORTS['MAKE-THE-WORLD'] = 
    new types.PrimProc('MAKE-THE-WORLD',
                 0, false, false,
                 function() {
                     var theWorld = THE_WORLD.makeTheWorld();
                     return theWorld;
                 });

EXPORTS['blob-handler'] =
    new types.PrimProc('blob-handler',
                 2,
                 false, false,
                 function(name, handler) {
                     return {name: name, handler: handler};
                 });

// Most programs shouldn't have access to primitive send, but it's
// useful for debugging.  It directly sends a signal to a blob with
// the given argument
EXPORTS['primitive-send'] =
    new types.PrimProc('primitive-send',
                       3, false, false,
                       function(blob, handlerName, handlerArg) {
                           blob.receive(String(handlerName), handlerArg);
                       });

EXPORTS['primitive-register'] = 
    new types.PrimProc('register',
                 3, false, false,
                 function(serverBlob, clientBlob, message) {
                     serverBlob.addListener(message, clientBlob);
                 });

EXPORTS['introduce'] =
    new types.PrimProc('introduce',
                       1, false, false,
                       function(blob) {
                           return new Introduction(blob);
                       });
EXPORTS['signal'] =
    new types.PrimProc('signal',
                       2, false, false,
                       function(handlerName, handlerArg) {
                           return new Signal(handlerName, handlerArg);
                       });

function makeToScreen(parentNode, blob) {
    var last = null;
    var screenBlob = new BLOBS.Blob(null, [{name: "on-screen",
                                            handler: function(thisblob, html) {
                                                console.log("Got some html: " + html);
                                                if(!(parentNode.innerHTML)) {
                                                    throw new Error("ParentNode didn't look like a DOM node in on-screen: " + parentNode);
                                                }
                                                if(!(html.innerHTML)) {
                                                    return new HandlerResult(null);
                                                }
                                                
                                                if(html === last) {
                                                    return new HandlerResult(null);
                                                }
                                                if(last !== null) {
                                                    parentNode.removeChild(last);
                                                }
                                                parentNode.appendChild(html);
                                                last = html;
                                                return new HandlerResult(null);
                                            }},
                                           {name: "init",
                                            handler: function() {
                                                blob.addListener("on-screen", screenBlob);
                                                return new HandlerResult(null);
                                            }}]);
    return screenBlob;
}

// Expects a parent node and another dom node to attach under it
EXPORTS['makeToScreen'] =
    new types.PrimProc('makeToScreen', 2, false, false, makeToScreen);

function makeTimer(interval) {
    var timerBlob = new BLOBS.Blob(null, [{name: "on-tick",
                                           handler: function(thisblob, t) {
                                               timerBlob.fire("on-tick", t);
                                               return new HandlerResult(t);
                                           }}]);
    setInterval(function() {
        timerBlob.receive("on-tick", interval);
    }, interval);
    return timerBlob;
}


EXPORTS['makeTimer'] = 
    new types.PrimProc('makeTimer', 1, false, false, makeTimer);

function inherit(obj, other, sig) {
    sig.forEach(function(propertyName) {
        if(!(propertyName in other)) {
            throw new Error("Inheriting non-present member " + propertyName + " from " + String(other));
        }
        obj[propertyName] = other[propertyName];
    });
}

// Buttons implement "on-button" for the moment.
// Don't know if we want to unify on-clicks from different dom node types,
// use the DOM's event model, etc.
function buttonBlob(v) {
    var node = document.createElement('button');
    node.appendChild(document.createTextNode(String(v)));
    var theButtonBlob = new BLOBS.Blob(v, [{name: "on-screen",
                                            handler: function(thisblob, _) {
                                                return node;
                                            }}]);
    node.onclick = function(e) {
        theButtonBlob.fire("on-button", v);
    }
    // These nodes are blobs *and* nodes --- can be the output to screen
    // and can fire events.
    inherit(node, theButtonBlob, BLOBS.blobSignature);
    return node;
}

EXPORTS['button-blob'] =
    new types.PrimProc('button-blob', 1, false, false, buttonBlob);

function divBlob(v) {
    var node = document.createElement('div');
    node.appendChild(document.createTextNode(String(v)));
    var theDivBlob = new BLOBS.Blob(v, [{name: "on-screen",
                                         handler: function(thisblob, _) {
                                             return node;
                                         }}]);
    
}

function div(nodes) {
    var div = document.createElement('div');
    var nodes = helpers.schemeListToArray(nodes);
    nodes.forEach(function(n) {
        if(!n.nodeType) {
            div.appendChild(document.createTextNode(String(n)));
        } 
        else {
            div.appendChild(n);
        }
    });
    return div;
}

EXPORTS['div'] = 
    new types.PrimProc('div', 1, false, false, div);

function getTopScreen() {
    return document.body;
}

EXPORTS['GET-TOP-SCREEN'] = 
        new types.PrimProc('GET-TOP-SCREEN', 0, false, false, getTopScreen);