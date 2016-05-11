class OauthController < ApplicationController

  def request_omniauth
    if is_admin
      redirect_to ConstantContact::Auth::OAuth2.new.get_authorization_url
    else
      redirect_to root_url
    end
  end

  def create_omniauth
    if is_admin
      oauth = ConstantContact::Auth::OAuth2.new
      if params[:code].present?
        response = oauth.get_access_token(params[:code])
        if response.present?
          token = response['access_token']

          current_organization.update(
            oauth_uid: params[:username],
            oauth_token: token,
            provider: 'constantcontact'
          )

          ConstantContactClient.create_contact_lists(current_organization)
        end
      end
    end

    redirect_to root_url
  end

  def destroy_omniauth
    organization = Maestrano::Connector::Rails::Organization.find_by_id(params[:organization_id])

    if organization && is_admin?(current_user, organization)
      organization.oauth_uid = nil
      organization.oauth_token = nil
      organization.refresh_token = nil
      organization.sync_enabled = false
      organization.save
    end

    redirect_to root_url
  end
end
