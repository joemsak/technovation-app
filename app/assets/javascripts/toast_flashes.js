// Available flash types: 'alert', 'error', 'notice', 'success'
// Available type modifiers: 'small'
// You can add a type and modifier by passing an array of multiple strings as the 'type' argument
function createFlashNotification(type, message, timeout) {
  var flashWrapper = document.createElement('div');
  if (Array.isArray(type)) {
    flashWrapper.classList.add('flash');
    type.forEach(function(type) {
      flashWrapper.classList.add('flash--' + type);
    });
  } else {
    flashWrapper.classList.add('flash', 'flash--' + type);
  }
  flashWrapper.innerHTML = message;
  if (timeout) {
    flashWrapper.dataset.timeout = timeout;
  }
  document.body.appendChild(flashWrapper);

  setTimeout(function() {
    flashWrapper.classList.add('flash--show');
  }, 0);
}

(function toastFlashes() {

  runFlashes();

  var observer = new MutationObserver(function(mutations) {
    var newFlashInDOM = mutations.reduce(function(reduction, mutation) {
      var isFlashMutation = mutation.addedNodes.length > 0
        && mutation.addedNodes[0].classList
        && mutation.addedNodes[0].classList.contains('flash');
      return reduction || isFlashMutation;
    }, false);


    if (newFlashInDOM) {
      setTimeout(runFlashes, 10);
    }
  });

  observer.observe(document.body, {
    attributes: true,
    childList: true,
    characterData: true,
    subtree: true
  });

  function runFlashes() {
    var flashes = document.getElementsByClassName('flash');
    var flashesCount = flashes.length;
    if (flashesCount === 0) {
      return;
    }


    for (var i = 0; i < flashesCount; i++) {
      var flash = flashes[i];
      flash.classList.add('flash--show');

      flash.addEventListener('click', function() {
        hideFlash(flash);
      });

      var timeout = flash.dataset.timeout ? flash.dataset.timeout : 4000;
      setTimeout(function() {
        hideFlash(flash);
      }, timeout);
    }
  }

  function hideFlash(flash) {
    flash.classList.remove('flash--show');
    flash.addEventListener('transitionend', function() {
      flash.remove();
    });
  }
})();