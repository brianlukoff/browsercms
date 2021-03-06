require 'test_helper'

module Cms

class LinksControllerPermissionsTest < ActionController::TestCase
  tests Cms::LinksController
  include Cms::ControllerTestHelper
  
  def setup 
    # DRYME copypaste from UserPermissionTest
    @user = Factory(:user)
    @group = Factory(:group, :name => "Test", :group_type => Factory(:group_type, :name => "CMS User", :cms_access => true))
    @group.permissions << create_or_find_permission_named("edit_content")
    @group.permissions << create_or_find_permission_named("publish_content")
    @user.groups << @group
    
    @editable_section = Factory(:section, :parent => root_section, :name => "Editable")
    @editable_subsection = Factory(:section, :parent => @editable_section, :name => "Editable Subsection")
    @group.sections << @editable_section
    @editable_page = Factory(:page, :section => @editable_section, :name => "Editable Page")
    @editable_subpage = Factory(:page, :section => @editable_subsection, :name => "Editable SubPage")
    @editable_link = Factory(:link, :section => @editable_section, :name => "Editable Link")
    @editable_sublink = Factory(:link, :section => @editable_subsection, :name => "Editable SubLink")
    
    @noneditable_section = Factory(:section, :parent => root_section, :name => "Not Editable")
    @noneditable_page = Factory(:page, :section => @noneditable_section, :name => "Non-Editable Page")
    @noneditable_link = Factory(:link, :section => @noneditable_section, :name => "Non-Editable Link")
    
    @noneditables = [@noneditable_section, @noneditable_page, @noneditable_link]
    @editables = [@editable_section, @editable_subsection, 
      @editable_page, @editable_subpage, 
      @editable_link, @editable_sublink]
  end

  def test_new_permissions
    login_as(@user)

    get :new, :section_id => @editable_section
    assert_response :success

    get :new, :section_id => @noneditable_section
    assert_response 403
    assert_template "cms/shared/access_denied"
  end

  def test_create_permissions
    login_as(@user)

    post :create, :section_id => @editable_section, :name => "Another editable link"
    assert_response :success

    post :create, :section_id => @noneditable_section, :name => "Another non-editable link"
    assert_response 403
    assert_template "cms/shared/access_denied"
  end

  def test_edit_permissions
    login_as(@user)

    get :edit, :id => @editable_link
    assert_response :success

    get :edit, :id => @noneditable_link
    assert_response 403
    assert_template "cms/shared/access_denied"
  end

  def test_update_permissions
    login_as(@user)

    put :update, :id => @editable_link, :name => "Modified editable link"
    assert_response :redirect

    put :update, :id => @noneditable_link, :name => "Modified non-editable link"
    assert_response 403
    assert_template "cms/shared/access_denied"
  end

  def test_destroy_permissions
    login_as(@user)

    delete :destroy, :id => @editable_link
    assert_response :redirect

    delete :destroy, :id => @noneditable_link
    assert_response 403
    assert_template "cms/shared/access_denied"
  end
end


end
