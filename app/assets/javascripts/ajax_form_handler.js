(function ajaxFormHandler() {
  var ajaxForms = document.querySelectorAll('[data-ajax-form]');
  if (ajaxForms.length === 0) {
    return;
  }

  for (var i = 0; i < ajaxForms.length; i++) {
    (function() {
      var wrapper = ajaxForms[i];
      var path = wrapper.dataset.updateUrl;
      var editButton = wrapper.querySelector('[data-action="edit"]');
      var objectName = wrapper.dataset.objectName;
      var namedInputs = wrapper.querySelectorAll('[name]');
      if (!path || !editButton) {
        throw new Error(
          'AJAX Forms must have an updateUrl data attribute, an edit button, '
          + 'an objectName (root param), and at least one named input'
        );
        return;
      }

      var currentData = {};
      Array.prototype.forEach.call(namedInputs, function(input) {
        currentData[input.name] = input.value;
      });

      editButton.addEventListener('click', editMode);

      var cancelButton;

      function editMode() {
        // General setup
        wrapper.classList.add('ajax-form--edit-mode');
        editButton.removeEventListener('click', editMode);

        // Turns Edit button into Save button
        editButton.innerText = 'Save';
        editButton.addEventListener('click', saveChanges);

        // Cancel button
        cancelButton = document.createElement('button');
        cancelButton.classList.add('appy-button');
        cancelButton.innerText = 'Cancel';
        editButton.parentElement.insertBefore(cancelButton, editButton);
        cancelButton.addEventListener('click', cancelEdit);
      }

      function validateChanges() {
        var valid = true;

        Array.prototype.forEach.call(namedInputs, function(input) {
          var validationStr = input.dataset.validateInput,
              errorEl = document.createElement('p'), 
              nextEl = input.nextElementSibling;

          if (nextEl && nextEl.classList.contains("error")) {
            nextEl.remove();
          }

          if (!input.value.match(new RegExp(validationStr))) {
            errorEl.classList.add('error');
            errorEl.innerText = input.dataset.validationMsg;
            input.after(errorEl);
            valid = false;
          }
        });

        return valid;
      }

      function saveChanges() {
        if (!validateChanges()) {
          return;
        }

        editButton.removeEventListener('click', saveChanges);

        var latestData = {};
        Array.prototype.forEach.call(namedInputs, function(input) {
          latestData[input.name] = input.value;
        });

        var payload = {};
        payload[objectName] = latestData;

        $.ajax(path, {
          method: 'PUT',
          data: payload,
          success: function(res, status) {
            createFlashNotification('success', 'Progress saved!');
            currentData = latestData;
            exitEditMode(res);
          },
          error: function(res, status) {
            var responseText = JSON.parse(res.responseText);
            var errorKeys = Object.keys(responseText);
            for (var i = 0; i < errorKeys.length; i++) {
              var currentError = errorKeys[i] + ' ' + responseText[errorKeys[i]];
              createFlashNotification('error', currentError);
            }
            cancelEdit();
          }
        });
      }

      function cancelEdit() {
        cancelButton.removeEventListener('click', cancelEdit);
        exitEditMode();
      }

      function exitEditMode(resp) {
        // Cleanup
        cancelButton.remove();
        wrapper.classList.remove('ajax-form--edit-mode');
        editButton.innerText = 'Edit';
        editButton.removeEventListener('click', saveChanges);
        editButton.addEventListener('click', editMode);

        // Parse the inputs and update the content of the static placeholders
        Object.keys(currentData).forEach(function(name) {
          var staticEl = wrapper.querySelector('[data-display-for="' + name +'"]');
          if (!staticEl) {
            return;
          }

          var currentInput = wrapper.querySelector('[name="' + name + '"]');
          var value = currentData[name];
          if (!value) {
            return;
          }

          var valueText;
          if (currentInput.tagName === 'SELECT') {
            valueText = currentInput.querySelector('[value="' + value + '"]').innerText;
          } else {
            valueText = value;
          }

          currentInput.value = value;

          var useResData = currentInput.dataset.useResponse;
          if (useResData !== undefined) {
            staticEl.innerHTML = resp[useResData];
          } else {
            staticEl.innerText = valueText;
          }
        });
      }
    })();
  }
})();