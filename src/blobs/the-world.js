var THE_WORLD = ((function () {
    
    function WorldHook(handlerName) {
        this.handlerName = handlerName;
    }

    var preventDefault = function(event) {
	if (event.preventDefault) {
	    event.preventDefault();
	} else {
	    event.returnValue = false;
	}
    }

    var stopPropagation = function(event) {
	if (event.stopPropagation) {
	    event.stopPropagation();
	} else {
	    event.cancelBubble = true;
	}
    }

    function onKey(theWorld) {
        document.addEventListener("keydown",
                                  function(e) {
                                      preventDefault(e);
                                      stopPropagation(e);
                                      theWorld.fire("on-key", helpers.getKeyCodeName(e));
                                  });
    }

    function makeTheWorld() {
        var theWorld = new BLOBS.Blob("THE-WORLD", []);
        onKey(theWorld);
        return theWorld;
    }

    return {
        makeTheWorld: makeTheWorld
    };

})());