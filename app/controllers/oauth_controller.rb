class OauthController < ApplicationController

  def request_omniauth
    if is_admin
      auth_params = {
        :org_uid => current_organization.uid
      }
      auth_params = URI.escape(auth_params.collect{|k,v| "#{k}=#{v}"}.join('&'))

      redirect_to "/auth/#{params[:provider]}?#{auth_params}"
    else
      redirect_to root_url
    end
  end

  def create_omniauth
    # add uid and token to organization
    org_uid = params[:org_uid]
    organization = Maestrano::Connector::Rails::Organization.find_by_uid_and_tenant(org_uid, current_user.tenant)
    organization.from_omniauth(env["omniauth.auth"]) if organization && is_admin?(current_user, organization)
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
