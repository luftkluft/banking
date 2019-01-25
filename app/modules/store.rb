module Store
  FILE_PATH = 'accounts.yml'.freeze

  def write_to_file(new_accounts)
    File.open(FILE_PATH, 'w') { |file| file.write new_accounts.to_yaml }
  end

  def accounts
    File.exist?(FILE_PATH) ? YAML.load_file(FILE_PATH) : []
  end

  def destroy_account_in_file(current_account)
    new_accounts = []
    accounts.each { |ac| ac.login == current_account.login ? true : new_accounts.push(ac) }
    write_to_file(new_accounts)
  end

  def new_accounts(current_account)
    new_accounts = []
    accounts.each do |account|
      return new_accounts << (account.login == current_account.login ? current_account : account)
    end
  end
end
