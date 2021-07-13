# frozen_string_literal: true

module DatabaseAdapter
  def concat(*args)
    if adapter =~ /mysql/i
      "CONCAT(#{args.join(',')})"
    else
      args.join('||')
    end
  end

  def adapter
    if ActiveRecord::Base.respond_to?(:connection_db_config)
      ActiveRecord::Base.connection_db_config.configuration_hash[:adapter]
    else
      ActiveRecord::Base.connection_config[:adapter]
    end
  end
end
