/* eslint-env browser */ // This allows us to reference 'window' below
import * as Cookies from 'js-cookie';
import { initAutocomplete } from '../../../utils/autoComplete';
import { isObject, isString } from '../../../utils/isType';
import getConstant from '../../../constants';

$(() => {
  initAutocomplete('#create-account-org-controls .autocomplete');
  initAutocomplete('#shib-ds-org-controls .autocomplete');

  const email = Cookies.get('dmproadmap_email');

  // Signin remember me
  // -----------------------------------------------------
  // If the user's email was stored in the browser's cookies the pre-populate the field
  if (email && email !== '') {
    $('#signin_create_form #remember_email').attr('checked', 'checked');
    $('#signin_create_form #user_email').val(email);
  }

  // When the user checks the 'remember email' box store the value in the browser storage
  $('#signin_create_form #remember_email').click((e) => {
    if ($(e.currentTarget).is(':checked')) {
      Cookies.set('dmproadmap_email', $('#signin_create_form #user_email').val(), { expires: 14 });
    } else {
      Cookies.remove('dmproadmap_email');
    }
  });

  // If the email is changed and the user has asked to remember it update the browser storage
  $('#signin_create_form #user_email').change((e) => {
    if ($('#signin_create_form #remember_email').is(':checked')) {
      Cookies.set('dmproadmap_email', $(e.currentTarget).val(), { expires: 14 });
    }
  });

  // Signin / Create Account form toggle
  // -----------------------------------------------------
  // handle toggling between shared signin/create account forms
  const toggleSignInCreateAccount = (signin = true) => {
    const signinTab = $('a[href="#sign-in-panel"]').closest('li');
    const createTab = $('a[href="#create-account-panel"]').closest('li');
    const signinPanel = $('#sign-in-panel');
    const createAccountPanel = $('#create-account-panel');

    if (signin) {
      signinTab.addClass('active');
      signinPanel.addClass('active');

      createTab.removeClass('active');
      createAccountPanel.removeClass('active');
    } else {
      signinTab.removeClass('active');
      signinPanel.removeClass('active');

      createTab.addClass('active');
      createAccountPanel.addClass('active');
    }
  };

  const clearLogo = () => {
    $('#org-sign-in-logo').html('');
    $('#user_org_id').val('');
  };

  $('#show-create-account-via-shib-ds, #show-create-account-form').click(() => {
    clearLogo();
    toggleSignInCreateAccount(false);
  });
  $('#show-sign-in-form').click(() => {
    clearLogo();
    toggleSignInCreateAccount(true);
  });

  // Shibboleth DS
  // -----------------------------------------------------
  const logoSuccess = (data) => {
    // Render the html in the org-sign-in modal
    if (isObject(data) && isObject(data.org) && isString(data.org.html)) {
      $('#org-sign-in-logo').html(data.org.html);
      $('#signin_user_org_id').val(data.org.id);
      $('#new_user_org_id').val(data.org.id);
      toggleSignInCreateAccount(true);
      $('#sign-in-create-account').modal('show');
    }
  };
  const logoError = () => {
    // There was an ajax error so just route the user to the sign-in modal
    // and let them sign in as a Non-Partner Institution
    $('#access-control-tabs a[data-target="#sign-in-form"]').tab('show');
  };

  $('.org-sign-in').click((e) => {
    const target = $(e.target);
    $('#org-sign-in').html('');
    $.ajax({
      method: 'GET',
      url: target.attr('href'),
    }).done((data) => {
      logoSuccess(data);
    }, logoError);
    e.preventDefault();
  });

  // Toggles the full Org list on/off
  $('#show_list').click((e) => {
    e.preventDefault();
    const target = $('#full_list');
    if (target.is('.hidden')) {
      target.removeClass('hidden').attr('aria-hidden', 'false');
      $(e.currentTarget).html(getConstant('SHIBBOLETH_DISCOVERY_SERVICE_HIDE_LIST'));
    } else {
      target.addClass('hidden').attr('aria-hidden', 'true');
      $(e.currentTarget).html(getConstant('SHIBBOLETH_DISCOVERY_SERVICE_SHOW_LIST'));
    }
  });

  // Only enable the Institutional Signin 'Go' Button if the user selected a
  // value from the list
  $('#shib-ds-org-controls').on('change', '#org_id', (e) => {
    const id = $(e.target);
    const json = JSON.parse(id.val());
    const button = $('#org-select-go');
    if (json !== undefined) {
      if (json.id !== undefined) {
        button.prop('disabled', false);
      } else {
        button.prop('disable', true);
      }
    }
  });

  // When the user selects an Org from the autocomplete and clicks 'Go'
  // click the matching link in the hidden full list of participating orgs
  $('#org-select-go').on('click', (e) => {
    const json = JSON.parse($('#shib-ds-org-controls #org_id').val());
    if (json !== undefined && json.id !== undefined) {
      const link = $(`#full_list li a[data-content="${json.id}"]`);
      // If its not shibbolized click the link to open the modal otherwise
      // just let the form submit
      if (link.attr('data-toggle') !== undefined) {
        e.preventDefault();
        link.click();
      }
    } else {
      e.preventDefault();
    }
  });

  // Hide the vanilla Roadmap 'Sign in with your institutional credentials' button
  $('#sign_in_form h4').addClass('hide');
  $('#sign_in_form a[href="/orgs/shibboleth"]').addClass('hide');

  // Get Started button click
  // -----------------------------------------------------
  $('#get-started').click((e) => {
    e.preventDefault();
    $('#header-signin').dropdown('toggle');
  });
});
