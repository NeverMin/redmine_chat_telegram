class TelegramGroupChatsController < ApplicationController
  unloadable

  def create
    cli_path = REDMINE_CHAT_TELEGRAM_CONFIG['telegram_cli_path']
    public_key_path = REDMINE_CHAT_TELEGRAM_CONFIG['telegram_cli_public_key_path']
    cli_base = "#{cli_path} -W -k #{public_key_path} -e "

    @issue = Issue.visible.find(params[:issue_id])

    subject = "#{@issue.project.name} ##{@issue.id}"
    bot_name = Setting.plugin_redmine_chat_telegram['bot_name']

    puts %x(#{cli_base} "create_group_chat \\"#{subject}\\" #{bot_name}" )

    cmd = "#{cli_base} \"export_chat_link #{subject.gsub(' ', '_').gsub('#', '@')}\""
    result = %x( #{cmd} )

    telegram_chat_url = result.match(/https:\/\/telegram.me\/joinchat\/[\w-]+/).to_s

    @issue.update_attribute :telegram_chat_url, telegram_chat_url
    redirect_to @issue
  end
end