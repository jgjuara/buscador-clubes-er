// JavaScript para manejo de chips de búsqueda

$(document).ready(function() {
  // Array para almacenar los términos de búsqueda
  let searchTerms = [];
  
  // Función para renderizar chips
  function renderChips() {
    const container = $('#chips-container');
    container.empty();
    
    if (searchTerms.length === 0) {
      container.append('<span class="chips-empty">Escribe términos de búsqueda y presiona Enter o Espacio</span>');
    } else {
      searchTerms.forEach(function(term, index) {
        const chip = $('<div class="search-chip">')
          .append($('<span>').text(term))
          .append($('<button class="chip-remove" data-index="' + index + '">×</button>'));
        container.append(chip);
      });
    }
    
    // Enviar términos al servidor
    Shiny.setInputValue('search_chips', searchTerms, {priority: 'event'});
  }
  
  // Función para agregar término
  function addTerm(term) {
    term = term.trim();
    if (term !== '' && !searchTerms.includes(term)) {
      searchTerms.push(term);
      renderChips();
    }
  }
  
  // Evento al presionar teclas en el input
  $('#search_input').on('keydown', function(e) {
    const value = $(this).val().trim();
    
    // Enter (13) o Espacio (32)
    if ((e.keyCode === 13 || e.keyCode === 32) && value !== '') {
      e.preventDefault();
      addTerm(value);
      $(this).val('');
    }
    
    // Backspace en input vacío: eliminar último chip
    if (e.keyCode === 8 && value === '' && searchTerms.length > 0) {
      e.preventDefault();
      searchTerms.pop();
      renderChips();
    }
  });
  
  // Evento para eliminar chip individual
  $(document).on('click', '.chip-remove', function() {
    const index = parseInt($(this).data('index'));
    searchTerms.splice(index, 1);
    renderChips();
  });
  
  // Botón limpiar
  $('#clear_search').on('click', function() {
    searchTerms = [];
    $('#search_input').val('');
    renderChips();
  });
  
  // Inicializar contenedor vacío
  renderChips();
  
  // Listener para cuando Shiny resetea la búsqueda
  Shiny.addCustomMessageHandler('reset_chips', function(message) {
    searchTerms = [];
    $('#search_input').val('');
    renderChips();
  });
});

