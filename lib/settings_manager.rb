# frozen_string_literal: true

# Source-License: Settings Management System
# Manages application configuration through database and environment variables

require 'yaml'
require 'json'

class SettingsManager
  # Define all configurable settings with their metadata
  SETTINGS_SCHEMA = {
    # Application Settings
    'app.name' => {
      type: 'string',
      default: 'Source-License',
      category: 'application',
      description: 'Application name displayed throughout the interface',
      web_editable: true,
    },
    'app.description' => {
      type: 'text',
      default: 'Professional license management system',
      category: 'application',
      description: 'Application description for SEO and branding',
      web_editable: true,
    },
    'app.contact_email' => {
      type: 'email',
      default: 'admin@example.com',
      category: 'application',
      description: 'Contact email for customer support',
      web_editable: true,
    },
    'app.support_email' => {
      type: 'email',
      default: 'support@yourdomain.com',
      category: 'application',
      description: 'Support email for customer inquiries',
      web_editable: true,
    },
    'app.organization_name' => {
      type: 'string',
      default: 'Your Organization',
      category: 'application',
      description: 'Organization name for branding and legal purposes',
      web_editable: true,
    },
    'app.organization_url' => {
      type: 'url',
      default: 'https://yourdomain.com',
      category: 'application',
      description: 'Organization website URL',
      web_editable: true,
    },
    'app.timezone' => {
      type: 'select',
      default: 'UTC',
      options: ['UTC', 'America/New_York', 'America/Los_Angeles', 'Europe/London', 'Asia/Tokyo'],
      category: 'application',
      description: 'Default timezone for the application',
      web_editable: true,
    },
    'app.environment' => {
      type: 'select',
      default: 'development',
      options: %w[development production test],
      category: 'application',
      description: 'Application environment mode',
      web_editable: false,
    },
    'app.version' => {
      type: 'string',
      default: '1.0.0',
      category: 'application',
      description: 'Application version number',
      web_editable: true,
    },
    'app.secret' => {
      type: 'password',
      default: '',
      category: 'application',
      description: 'Application secret key for sessions and encryption',
      web_editable: false,
      sensitive: true,
    },
    'app.host' => {
      type: 'string',
      default: 'localhost',
      category: 'application',
      description: 'Application host/domain name',
      web_editable: true,
    },
    'app.port' => {
      type: 'number',
      default: 4567,
      category: 'application',
      description: 'Application port number',
      web_editable: true,
    },

    # Social Media Settings
    'social.enable_social_links' => {
      type: 'boolean',
      default: false,
      category: 'social',
      description: 'Enable social media links in footer',
      web_editable: true,
    },
    'social.enable_github' => {
      type: 'boolean',
      default: false,
      category: 'social',
      description: 'Show GitHub link in footer',
      web_editable: true,
    },
    'social.github_url' => {
      type: 'url',
      default: '',
      category: 'social',
      description: 'GitHub profile or organization URL',
      web_editable: true,
    },
    'social.enable_twitter' => {
      type: 'boolean',
      default: false,
      category: 'social',
      description: 'Show Twitter/X link in footer',
      web_editable: true,
    },
    'social.twitter_url' => {
      type: 'url',
      default: '',
      category: 'social',
      description: 'Twitter/X profile URL',
      web_editable: true,
    },
    'social.enable_linkedin' => {
      type: 'boolean',
      default: false,
      category: 'social',
      description: 'Show LinkedIn link in footer',
      web_editable: true,
    },
    'social.linkedin_url' => {
      type: 'url',
      default: '',
      category: 'social',
      description: 'LinkedIn profile or company page URL',
      web_editable: true,
    },
    'social.enable_facebook' => {
      type: 'boolean',
      default: false,
      category: 'social',
      description: 'Show Facebook link in footer',
      web_editable: true,
    },
    'social.facebook_url' => {
      type: 'url',
      default: '',
      category: 'social',
      description: 'Facebook page URL',
      web_editable: true,
    },
    'social.enable_youtube' => {
      type: 'boolean',
      default: false,
      category: 'social',
      description: 'Show YouTube link in footer',
      web_editable: true,
    },
    'social.youtube_url' => {
      type: 'url',
      default: '',
      category: 'social',
      description: 'YouTube channel URL',
      web_editable: true,
    },
    'social.enable_discord' => {
      type: 'boolean',
      default: false,
      category: 'social',
      description: 'Show Discord link in footer',
      web_editable: true,
    },
    'social.discord_url' => {
      type: 'url',
      default: '',
      category: 'social',
      description: 'Discord server invite URL',
      web_editable: true,
    },

    # Payment Settings
    'payment.stripe.publishable_key' => {
      type: 'string',
      default: '',
      category: 'payment',
      description: 'Stripe publishable key for payment processing',
      web_editable: true,
      sensitive: false,
    },
    'payment.stripe.secret_key' => {
      type: 'password',
      default: '',
      category: 'payment',
      description: 'Stripe secret key for payment processing',
      web_editable: true,
      sensitive: true,
    },
    'payment.stripe.webhook_secret' => {
      type: 'password',
      default: '',
      category: 'payment',
      description: 'Stripe webhook secret for security',
      web_editable: true,
      sensitive: true,
    },
    'payment.paypal.client_id' => {
      type: 'string',
      default: '',
      category: 'payment',
      description: 'PayPal client ID for payment processing',
      web_editable: true,
      sensitive: false,
    },
    'payment.paypal.client_secret' => {
      type: 'password',
      default: '',
      category: 'payment',
      description: 'PayPal client secret for payment processing',
      web_editable: true,
      sensitive: true,
    },
    'payment.paypal.environment' => {
      type: 'select',
      default: 'sandbox',
      options: %w[sandbox production],
      category: 'payment',
      description: 'PayPal environment (sandbox for testing)',
      web_editable: true,
    },

    # Email Settings
    'email.smtp.host' => {
      type: 'string',
      default: '',
      category: 'email',
      description: 'SMTP server hostname',
      web_editable: true,
    },
    'email.smtp.port' => {
      type: 'number',
      default: 587,
      category: 'email',
      description: 'SMTP server port (587 for TLS, 465 for SSL)',
      web_editable: true,
    },
    'email.smtp.username' => {
      type: 'string',
      default: '',
      category: 'email',
      description: 'SMTP authentication username',
      web_editable: true,
    },
    'email.smtp.password' => {
      type: 'password',
      default: '',
      category: 'email',
      description: 'SMTP authentication password',
      web_editable: true,
      sensitive: true,
    },
    'email.smtp.tls' => {
      type: 'boolean',
      default: true,
      category: 'email',
      description: 'Enable TLS encryption for SMTP',
      web_editable: true,
    },
    'email.from_name' => {
      type: 'string',
      default: 'Source License',
      category: 'email',
      description: 'From name for outgoing emails',
      web_editable: true,
    },
    'email.from_address' => {
      type: 'email',
      default: '',
      category: 'email',
      description: 'From address for outgoing emails',
      web_editable: true,
    },

    # Security Settings
    'security.jwt_secret' => {
      type: 'password',
      default: '',
      category: 'security',
      description: 'JWT secret key for token signing',
      web_editable: false,
      sensitive: true,
    },
    'security.allowed_hosts' => {
      type: 'text',
      default: 'localhost,127.0.0.1,yourdomain.com,www.yourdomain.com',
      category: 'security',
      description: 'Comma-separated list of allowed hostnames',
      web_editable: true,
    },
    'security.allowed_origins' => {
      type: 'text',
      default: 'https://yourdomain.com,https://www.yourdomain.com',
      category: 'security',
      description: 'Comma-separated list of allowed CORS origins',
      web_editable: true,
    },
    'security.force_ssl' => {
      type: 'boolean',
      default: true,
      category: 'security',
      description: 'Force HTTPS/SSL connections',
      web_editable: true,
    },
    'security.hsts_max_age' => {
      type: 'number',
      default: 31_536_000,
      category: 'security',
      description: 'HTTP Strict Transport Security max age in seconds',
      web_editable: true,
    },
    'security.password_expiry_days' => {
      type: 'number',
      default: 90,
      category: 'security',
      description: 'Number of days before passwords expire',
      web_editable: true,
    },
    'security.max_login_attempts' => {
      type: 'number',
      default: 5,
      category: 'security',
      description: 'Maximum failed login attempts before lockout',
      web_editable: true,
    },
    'security.lockout_duration_minutes' => {
      type: 'number',
      default: 30,
      category: 'security',
      description: 'Account lockout duration in minutes',
      web_editable: true,
    },
    'security.session_timeout_hours' => {
      type: 'number',
      default: 8,
      category: 'security',
      description: 'Session timeout in hours',
      web_editable: true,
    },
    'security.session_timeout' => {
      type: 'number',
      default: 28_800,
      category: 'security',
      description: 'Session timeout in seconds',
      web_editable: true,
    },
    'security.session_rotation_interval' => {
      type: 'number',
      default: 7200,
      category: 'security',
      description: 'Session rotation interval in seconds',
      web_editable: true,
    },
    'security.behind_load_balancer' => {
      type: 'boolean',
      default: false,
      category: 'security',
      description: 'Application is behind a load balancer',
      web_editable: true,
    },

    # License Settings
    'license.default_validity_days' => {
      type: 'number',
      default: 365,
      category: 'license',
      description: 'Default license validity period in days',
      web_editable: true,
    },
    'license.max_activations' => {
      type: 'number',
      default: 3,
      category: 'license',
      description: 'Default maximum activations per license',
      web_editable: true,
    },
    'license.allow_deactivation' => {
      type: 'boolean',
      default: true,
      category: 'license',
      description: 'Allow users to deactivate license on devices',
      web_editable: true,
    },

    # Tax Settings
    'tax.enable_taxes' => {
      type: 'boolean',
      default: false,
      category: 'tax',
      description: 'Enable tax calculation for orders',
      web_editable: true,
    },
    'tax.auto_apply_taxes' => {
      type: 'boolean',
      default: true,
      category: 'tax',
      description: 'Automatically apply active taxes to all orders',
      web_editable: true,
    },
    'tax.display_tax_breakdown' => {
      type: 'boolean',
      default: true,
      category: 'tax',
      description: 'Show detailed tax breakdown to customers',
      web_editable: true,
    },
    'tax.include_tax_in_price' => {
      type: 'boolean',
      default: false,
      category: 'tax',
      description: 'Include tax in displayed prices (tax-inclusive pricing)',
      web_editable: true,
    },
    'tax.default_tax_name' => {
      type: 'string',
      default: 'Sales Tax',
      category: 'tax',
      description: 'Default name for new taxes',
      web_editable: true,
    },
    'tax.default_tax_rate' => {
      type: 'number',
      default: 0.0,
      category: 'tax',
      description: 'Default tax rate percentage for new taxes',
      web_editable: true,
    },
    'tax.round_tax_amounts' => {
      type: 'boolean',
      default: true,
      category: 'tax',
      description: 'Round tax amounts to nearest cent',
      web_editable: true,
    },

    # Monitoring Settings
    'monitoring.error_tracking_dsn' => {
      type: 'string',
      default: '',
      category: 'monitoring',
      description: 'Error tracking service DSN (Sentry, Bugsnag, etc.)',
      web_editable: true,
      sensitive: true,
    },
    'monitoring.security_webhook_url' => {
      type: 'url',
      default: '',
      category: 'monitoring',
      description: 'Webhook URL for security alerts (Slack, etc.)',
      web_editable: true,
      sensitive: true,
    },
    'monitoring.log_level' => {
      type: 'select',
      default: 'info',
      options: %w[debug info warn error fatal],
      category: 'monitoring',
      description: 'Application log level',
      web_editable: true,
    },
    'monitoring.log_format' => {
      type: 'select',
      default: 'text',
      options: %w[text json],
      category: 'monitoring',
      description: 'Log output format (JSON recommended for production)',
      web_editable: true,
    },

    # Performance & Caching Settings
    'performance.redis_url' => {
      type: 'string',
      default: 'redis://localhost:6379/0',
      category: 'performance',
      description: 'Redis server URL for caching',
      web_editable: true,
    },
    'performance.enable_caching' => {
      type: 'boolean',
      default: true,
      category: 'performance',
      description: 'Enable application caching',
      web_editable: true,
    },
    'performance.cache_ttl' => {
      type: 'number',
      default: 3600,
      category: 'performance',
      description: 'Cache time-to-live in seconds',
      web_editable: true,
    },
    'performance.db_pool_size' => {
      type: 'number',
      default: 10,
      category: 'performance',
      description: 'Database connection pool size',
      web_editable: true,
    },
    'performance.db_timeout' => {
      type: 'number',
      default: 5000,
      category: 'performance',
      description: 'Database connection timeout in milliseconds',
      web_editable: true,
    },
    'performance.rate_limit_requests_per_hour' => {
      type: 'number',
      default: 1000,
      category: 'performance',
      description: 'Rate limit for general requests per hour',
      web_editable: true,
    },
    'performance.rate_limit_admin_requests_per_hour' => {
      type: 'number',
      default: 100,
      category: 'performance',
      description: 'Rate limit for admin requests per hour',
      web_editable: true,
    },

    # Database Settings (mostly read-only in web interface)
    'database.adapter' => {
      type: 'select',
      default: 'mysql',
      options: %w[mysql postgresql sqlite],
      category: 'database',
      description: 'Database adapter type',
      web_editable: false,
    },
    'database.host' => {
      type: 'string',
      default: 'localhost',
      category: 'database',
      description: 'Database server hostname',
      web_editable: false,
    },
    'database.port' => {
      type: 'number',
      default: 3306,
      category: 'database',
      description: 'Database server port',
      web_editable: false,
    },
    'database.name' => {
      type: 'string',
      default: 'source_license',
      category: 'database',
      description: 'Database name',
      web_editable: false,
    },
    'database.user' => {
      type: 'string',
      default: '',
      category: 'database',
      description: 'Database username',
      web_editable: false,
      sensitive: false,
    },
    'database.password' => {
      type: 'password',
      default: '',
      category: 'database',
      description: 'Database password',
      web_editable: false,
      sensitive: true,
    },

    # Admin Setup Settings
    'admin.initial_email' => {
      type: 'email',
      default: 'admin@yourdomain.com',
      category: 'admin',
      description: 'Initial admin account email (used during installation)',
      web_editable: false,
      sensitive: false,
    },
    'admin.initial_password' => {
      type: 'password',
      default: '',
      category: 'admin',
      description: 'Initial admin account password (remove after first login)',
      web_editable: false,
      sensitive: true,
    },

    # File Storage Settings
    'storage.downloads_path' => {
      type: 'string',
      default: './downloads',
      category: 'storage',
      description: 'Path for downloadable files',
      web_editable: true,
    },
    'storage.licenses_path' => {
      type: 'string',
      default: './licenses',
      category: 'storage',
      description: 'Path for license files',
      web_editable: true,
    },
  }.freeze

  class << self
    # Get setting value (first check database, then environment, then default)
    def get(key)
      # Try database first
      if defined?(DB) && DB.table_exists?(:settings)
        setting = DB[:settings].where(key: key).first
        return parse_value(setting[:value], get_schema(key)[:type]) if setting
      end

      # Try environment variable
      env_key = key_to_env(key)
      env_value = ENV.fetch(env_key, nil)
      return parse_value(env_value, get_schema(key)[:type]) if env_value

      # Return default
      get_schema(key)[:default]
    end

    # Set setting value in database
    def set(key, value)
      return false unless valid_key?(key)

      schema = get_schema(key)
      return false unless validate_value(value, schema)

      ensure_settings_table

      # Convert value to string for storage
      stored_value = serialize_value(value, schema[:type])

      if DB[:settings].where(key: key).any?
        DB[:settings].where(key: key).update(
          value: stored_value,
          updated_at: Time.now
        )
      else
        DB[:settings].insert(
          key: key,
          value: stored_value,
          created_at: Time.now,
          updated_at: Time.now
        )
      end

      # Update environment variable if it exists
      env_key = key_to_env(key)
      ENV[env_key] = stored_value if ENV.key?(env_key)

      true
    end

    # Get all settings for a category
    def get_category(category)
      SETTINGS_SCHEMA.filter_map do |key, schema|
        next unless schema[:category] == category

        {
          key: key,
          value: get(key),
          schema: schema,
        }
      end
    end

    # Get all categories
    def get_categories
      SETTINGS_SCHEMA.values.map { |s| s[:category] }.uniq.sort
    end

    # Get web-editable settings
    def get_web_editable
      SETTINGS_SCHEMA.filter_map do |key, schema|
        next unless schema[:web_editable]

        {
          key: key,
          value: get(key),
          schema: schema,
        }
      end
    end

    # Export settings to YAML
    def export_to_yaml
      settings = {}
      SETTINGS_SCHEMA.each_key do |key|
        value = get(key)
        settings[key] = value unless value == get_schema(key)[:default]
      end
      settings.to_yaml
    end

    # Import settings from YAML
    def import_from_yaml(yaml_content)
      settings = YAML.safe_load(yaml_content)
      imported = 0

      settings.each do |key, value|
        imported += 1 if valid_key?(key) && set(key, value)
      end

      imported
    end

    # Generate .env file content
    def generate_env_file
      lines = ["# Generated .env file - #{Time.now}"]

      get_categories.each do |category|
        lines << ''
        lines << "# #{category.capitalize} Settings"

        get_category(category).each do |setting|
          env_key = key_to_env(setting[:key])
          value = setting[:value]

          # Skip empty values
          next if value.nil? || value == ''

          # Add description as comment
          lines << "# #{setting[:schema][:description]}"
          lines << "#{env_key}=#{value}"
        end
      end

      lines.join("\n")
    end

    # Test configuration values
    def test_configuration(category = nil)
      results = {}

      categories = category ? [category] : get_categories

      categories.each do |cat|
        results[cat] = test_category_configuration(cat)
      end

      results
    end

    private

    def get_schema(key)
      SETTINGS_SCHEMA[key] || { type: 'string', default: nil, category: 'unknown' }
    end

    def valid_key?(key)
      SETTINGS_SCHEMA.key?(key)
    end

    def key_to_env(key)
      # Convert dot notation to uppercase env var with specific mappings
      # e.g., "app.name" -> "APP_NAME"
      #       "payment.stripe.secret_key" -> "STRIPE_SECRET_KEY"

      case key
      # Application settings
      when 'app.name'
        'APP_NAME'
      when 'app.environment'
        'APP_ENV'
      when 'app.secret'
        'APP_SECRET'
      when 'app.host'
        'APP_HOST'
      when 'app.port'
        'PORT'
      when 'app.version'
        'APP_VERSION'
      when 'app.support_email'
        'SUPPORT_EMAIL'
      when 'app.organization_name'
        'ORGANIZATION_NAME'
      when 'app.organization_url'
        'ORGANIZATION_URL'

      # Payment settings
      when /^payment\.stripe\.(.+)/
        "STRIPE_#{::Regexp.last_match(1).upcase}"
      when /^payment\.paypal\.(.+)/
        "PAYPAL_#{::Regexp.last_match(1).upcase}"

      # Email settings
      when /^email\.smtp\.(.+)/
        "SMTP_#{::Regexp.last_match(1).upcase}"

      # Security settings
      when 'security.jwt_secret'
        'JWT_SECRET'
      when 'security.allowed_hosts'
        'ALLOWED_HOSTS'
      when 'security.allowed_origins'
        'ALLOWED_ORIGINS'
      when 'security.force_ssl'
        'FORCE_SSL'
      when 'security.hsts_max_age'
        'HSTS_MAX_AGE'
      when 'security.session_timeout'
        'SESSION_TIMEOUT'
      when 'security.session_rotation_interval'
        'SESSION_ROTATION_INTERVAL'
      when 'security.behind_load_balancer'
        'BEHIND_LOAD_BALANCER'

      # License settings
      when 'license.default_validity_days'
        'LICENSE_VALIDITY_DAYS'
      when 'license.max_activations'
        'MAX_ACTIVATIONS_PER_LICENSE'

      # Monitoring settings
      when /^monitoring\.(.+)/
        case ::Regexp.last_match(1)
        when 'error_tracking_dsn'
          'ERROR_TRACKING_DSN'
        when 'security_webhook_url'
          'SECURITY_WEBHOOK_URL'
        when 'log_level'
          'LOG_LEVEL'
        when 'log_format'
          'LOG_FORMAT'
        else
          ::Regexp.last_match(1).upcase
        end

      # Performance settings
      when 'performance.redis_url'
        'REDIS_URL'
      when 'performance.enable_caching'
        'ENABLE_CACHING'
      when 'performance.cache_ttl'
        'CACHE_TTL'
      when 'performance.db_pool_size'
        'DB_POOL_SIZE'
      when 'performance.db_timeout'
        'DB_TIMEOUT'
      when 'performance.rate_limit_requests_per_hour'
        'RATE_LIMIT_REQUESTS_PER_HOUR'
      when 'performance.rate_limit_admin_requests_per_hour'
        'RATE_LIMIT_ADMIN_REQUESTS_PER_HOUR'

      # Database settings
      when /^database\.(.+)/
        "DATABASE_#{::Regexp.last_match(1).upcase}"

      # Admin settings
      when 'admin.initial_email'
        'INITIAL_ADMIN_EMAIL'
      when 'admin.initial_password'
        'INITIAL_ADMIN_PASSWORD'

      # Storage settings
      when 'storage.downloads_path'
        'DOWNLOADS_PATH'
      when 'storage.licenses_path'
        'LICENSES_PATH'

      # Social media settings
      when 'social.enable_social_links'
        'ENABLE_SOCIAL_LINKS'
      when 'social.enable_github'
        'ENABLE_GITHUB'
      when 'social.github_url'
        'SOCIAL_GITHUB_URL'
      when 'social.enable_twitter'
        'ENABLE_TWITTER'
      when 'social.twitter_url'
        'SOCIAL_TWITTER_URL'
      when 'social.enable_linkedin'
        'ENABLE_LINKEDIN'
      when 'social.linkedin_url'
        'SOCIAL_LINKEDIN_URL'
      when 'social.enable_facebook'
        'ENABLE_FACEBOOK'
      when 'social.facebook_url'
        'SOCIAL_FACEBOOK_URL'
      when 'social.enable_youtube'
        'ENABLE_YOUTUBE'
      when 'social.youtube_url'
        'SOCIAL_YOUTUBE_URL'
      when 'social.enable_discord'
        'ENABLE_DISCORD'
      when 'social.discord_url'
        'SOCIAL_DISCORD_URL'

      # Default fallback
      else
        key.tr('.', '_').upcase
      end
    end

    def parse_value(value, type)
      return nil if value.nil? || value == ''

      case type
      when 'boolean'
        %w[true 1 yes on].include?(value.to_s.downcase)
      when 'number'
        value.to_i
      when 'float'
        value.to_f
      else
        value.to_s
      end
    end

    def serialize_value(value, type)
      case type
      when 'boolean'
      when 'number', 'float'
      end
      value.to_s
    end

    def validate_value(value, schema)
      case schema[:type]
      when 'email'
        value.to_s.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
      when 'url'
        value.to_s.match?(/\Ahttps?:\/\//)
      when 'number'
        value.to_s.match?(/\A\d+\z/)
      when 'select'
        schema[:options]&.include?(value.to_s)
      else
        true
      end
    end

    def ensure_settings_table
      return if DB.table_exists?(:settings)

      DB.create_table :settings do
        primary_key :id
        String :key, null: false, unique: true
        Text :value
        DateTime :created_at
        DateTime :updated_at
      end
    end

    def test_category_configuration(category)
      results = {}

      case category
      when 'email'
        results = test_email_configuration
      when 'payment'
        results = test_payment_configuration
      when 'monitoring'
        results = test_monitoring_configuration
      when 'database'
        results = test_database_configuration
      when 'performance'
        results = test_performance_configuration
      when 'security'
        results = test_security_configuration
      when 'application'
        results = test_application_configuration
      else
        results[:status] = 'ok'
        results[:message] = 'No specific tests for this category'
      end

      results
    end

    def test_email_configuration
      host = get('email.smtp.host')
      port = get('email.smtp.port')

      return { status: 'disabled', message: 'SMTP not configured' } if host.empty?

      begin
        require 'net/smtp'

        smtp = Net::SMTP.new(host, port)
        smtp.enable_starttls if get('email.smtp.tls')
        smtp.start(host, get('email.smtp.username'), get('email.smtp.password'), :auto)
        smtp.finish

        { status: 'ok', message: 'SMTP connection successful' }
      rescue StandardError => e
        { status: 'error', message: "SMTP connection failed: #{e.message}" }
      end
    end

    def test_payment_configuration
      stripe_key = get('payment.stripe.secret_key')
      paypal_id = get('payment.paypal.client_id')

      return { status: 'warning', message: 'No payment gateways configured' } if stripe_key.empty? && paypal_id.empty?

      results = []

      results << test_stripe_configuration unless stripe_key.empty?

      results << test_paypal_configuration unless paypal_id.empty?

      if results.any? { |r| r[:status] == 'error' }
        { status: 'error', message: 'Payment configuration errors detected' }
      elsif results.any? { |r| r[:status] == 'ok' }
        { status: 'ok', message: 'Payment gateways configured' }
      else
        { status: 'warning', message: 'Payment gateways configured but not tested' }
      end
    end

    def test_stripe_configuration
      # Basic Stripe key validation
      secret_key = get('payment.stripe.secret_key')

      if secret_key.start_with?('sk_')
        { status: 'ok', message: 'Stripe key format valid' }
      else
        { status: 'error', message: 'Invalid Stripe secret key format' }
      end
    end

    def test_paypal_configuration
      # Basic PayPal configuration validation
      client_id = get('payment.paypal.client_id')

      if client_id.length > 20
        { status: 'ok', message: 'PayPal client ID format valid' }
      else
        { status: 'error', message: 'Invalid PayPal client ID format' }
      end
    end

    def test_monitoring_configuration
      dsn = get('monitoring.error_tracking_dsn')
      webhook = get('monitoring.security_webhook_url')

      return { status: 'disabled', message: 'Monitoring not configured' } if dsn.empty? && webhook.empty?

      { status: 'ok', message: 'Monitoring services configured' }
    end

    def test_database_configuration
      DB.test_connection
      { status: 'ok', message: 'Database connection successful' }
    rescue StandardError => e
      { status: 'error', message: "Database connection failed: #{e.message}" }
    end

    def test_performance_configuration
      redis_url = get('performance.redis_url')

      return { status: 'disabled', message: 'Redis not configured' } if redis_url.empty?

      begin
        # Basic Redis URL validation
        if redis_url.start_with?('redis://')
          { status: 'ok', message: 'Redis URL format valid' }
        else
          { status: 'warning', message: 'Redis URL format may be invalid' }
        end
      rescue StandardError => e
        { status: 'error', message: "Redis configuration error: #{e.message}" }
      end
    end

    def test_security_configuration
      issues = []

      # Check for strong secrets
      app_secret = get('app.secret')
      jwt_secret = get('security.jwt_secret')

      issues << 'APP_SECRET not configured' if app_secret.empty?
      issues << 'JWT_SECRET not configured' if jwt_secret.empty?
      issues << 'APP_SECRET too short' if app_secret.length < 32
      issues << 'JWT_SECRET too short' if jwt_secret.length < 32

      # Check SSL configuration
      issues << 'SSL not enforced' unless get('security.force_ssl')

      if issues.any?
        { status: 'warning', message: "Security issues: #{issues.join(', ')}" }
      else
        { status: 'ok', message: 'Security configuration looks good' }
      end
    end

    def test_application_configuration
      issues = []

      # Check required application settings
      app_name = get('app.name')
      support_email = get('app.support_email')

      issues << 'Application name not configured' if app_name.empty?
      issues << 'Support email not configured' if support_email.empty?

      # Check if in production with development settings
      if get('app.environment') == 'production'
        issues << 'Using default host in production' if get('app.host') == 'localhost'
        issues << 'Using default port in production' if get('app.port') == 4567
      end

      if issues.any?
        { status: 'warning', message: "Configuration issues: #{issues.join(', ')}" }
      else
        { status: 'ok', message: 'Application configuration looks good' }
      end
    end
  end
end
