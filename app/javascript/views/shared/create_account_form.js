import { initAutocomplete } from '../../utils/autoComplete';
import { togglisePasswords } from '../../utils/passwordHelper';

$(() => {
  // START: DMPTOOL customization
  // --------------------------------------------------
  // TODO: Just change the control name in our branding!
  // const options = { selector: '#create-account-form' };
  const options = { selector: '#create_account_form' };
  // --------------------------------------------------
  // END: DMPTool customization

  initAutocomplete('#create-account-org-controls .autocomplete');
  togglisePasswords(options);
});
