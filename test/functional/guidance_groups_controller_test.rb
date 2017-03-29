class GuidanceGroupsControllerTest < ActionDispatch::IntegrationTest
  
  include Devise::Test::IntegrationHelpers

  # TODO: The following methods SHOULD replace the old 'admin_' prefixed methods. The routes file already has
  #       these defined. They are defined multiple times though and we need to clean this up! In particular
  #       look at the unnamed routes after 'new_plan_phase' below. They are not named because they are duplicates.
  #       We should just have:
  #
  # SHOULD BE:
  # --------------------------------------------------
  #   guidance_groups      GET    /guidance_groups        guidance_groups#index
  #                        POST   /guidance_groups        guidance_groups#create
  #   guidance_group       GET    /guidance_group/:id     guidance_groups#show
  #                        PATCH  /guidance_groups/:id    guidance_groups#update
  #                        PUT    /guidance_groups/:id    guidance_groups#update
  #                        DELETE /guidance_groups/:id    guidance_groups#destroy
  #
  # CURRENT RESULTS OF `rake routes`
  # --------------------------------------------------
  #   admin_show_guidance_group     GET      /org/admin/guidancegroup/:id/admin_show    guidance_groups#admin_show
  #   admin_new_guidance_group      GET      /org/admin/guidancegroup/:id/admin_new     guidance_groups#admin_new
  #   admin_edit_guidance_group     GET      /org/admin/guidancegroup/:id/admin_edit    guidance_groups#admin_edit
  #   admin_destroy_guidance_group  DELETE   /org/admin/guidancegroup/:id/admin_destroy guidance_groups#admin_destroy
  #   admin_create_guidance_group   POST     /org/admin/guidancegroup/:id/admin_create  guidance_groups#admin_create
  #   admin_update_guidance_group   PUT      /org/admin/guidancegroup/:id/admin_update  guidance_groups#admin_update

  setup do
    @user = User.where(org: GuidanceGroup.first.org).select{|u| u.can_org_admin?}.first
  end
  
  # GET /org/admin/guidancegroup/:id/admin_show (admin_show_guidance_group_path)
  # ----------------------------------------------------------
  test 'show the guidance_group' do
    # Should redirect user to the root path if they are not logged in!
    get admin_show_guidance_group_path(GuidanceGroup.find_by(org: @user.org))
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_show_guidance_group_path(GuidanceGroup.find_by(org: @user.org))
    assert_response :success
  end

  # GET /org/admin/guidancegroup/:id/admin_new (admin_new_guidance_group_path)
  # ----------------------------------------------------------
  test 'load the new guidance_group page' do
    # Should redirect user to the root path if they are not logged in!
    # TODO: Why is there an id here!? its a new guidance_group!
    get admin_new_guidance_group_path(@user.org)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_new_guidance_group_path(@user.org)
    assert_response :success
  end
  
  # POST /org/admin/guidancegroup/:id/admin_create (admin_create_guidance_group_path)
  # ----------------------------------------------------------
  test 'create a new guidance_group' do
    
  end
  
  # GET /org/admin/guidancegroup/:id/admin_edit (admin_edit_guidance_group_path)
  # ----------------------------------------------------------
  test 'load the edit guidance_group page' do
    # Should redirect user to the root path if they are not logged in!
    get admin_edit_guidance_group_path(GuidanceGroup.find_by(org: @user.org))
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_edit_guidance_group_path(GuidanceGroup.find_by(org: @user.org))
    assert_response :success
  end
  
  # PUT /org/admin/templates/:id/admin_template (admin_update_guidance_group_path)
  # ----------------------------------------------------------
  test 'update the guidance_group' do
    
  end
  
  # PUT /org/admin/guidancegroup/:id/admin_update (admin_update_guidance_group_path)
  # ----------------------------------------------------------
  test 'publish the guidance_group' do
    
  end
  
  # DELETE /org/admin/guidancegroup/:id/admin_destroy (admin_destroy_guidance_group_path)
  # ----------------------------------------------------------
  test 'delete the guidance_group' do
    
  end
  
end