RailsAdmin.config do |config|
  config.asset_source = :sprockets

  ### Popular gems integration

  ##### == Devise連携 == #####
  # 管理画面にアクセスする前に認証を行うための設定。Devise の warden.authenticate! メソッドを使用。
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  # Rails_adminでcurrent_userを使用するためのメソッド。
  config.current_user_method(&:current_user)

  ##### == CancanCan連携 == #####
  # Rails_adminでのアクセス制限にcancancanを使用するための設定。
  # Abilityクラスで定義されたアクセス権限が適用される。
  config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/railsadminteam/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  config.model 'Quiz' do
    label 'クイズ'

    list do
      field :id
      field :name
      field :categories
      field :give_point
    end

    edit do
      field :name
      field :sentence do
        label '問題文'
        html_attributes rows: 10
      end

      field :explanation do
        label '解説'
        html_attributes rows: 10
      end
      field :give_point
      field :categories
      field :choices
    end
  end
end
