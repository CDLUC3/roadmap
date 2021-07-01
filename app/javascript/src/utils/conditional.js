// Toggle (hide/show) the additional fields related to the context

const toggleConditionalFields = (context, displayFields) => {
  if (context.length > 0) {
    const container = $(context).closest('conditional');

    if (container.length > 0) {
      if (displayFields === true) {
        container.find('.toggleable-field').show();
      } else {
        container.find('input.toggleable-field, textarea.toggleable-field').val('');
        container.find('.toggleable-field').hide();
      }
    }
  }
};

export default toggleConditionalFields;
