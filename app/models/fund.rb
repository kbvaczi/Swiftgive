class Fund < ActiveRecord::Base

  # ----- Table Setup ----- #

  self.table_name = 'funds'
  
  has_many    :memberships,     :class_name => 'Funds::Membership', :foreign_key => :fund_id, :dependent => :destroy
  has_many    :members,         :class_name => "Account",           :through => :memberships, :source => :member
  has_many    :ownerships,      :class_name => 'Funds::Membership', :foreign_key => :fund_id, :conditions => { :is_owner => true }  
  has_many    :owners,          :class_name => "Account",           :through => :ownerships,  :source => :member

  has_one     :bank_account,    :class_name => 'BankAccount',       :conditions => { :is_active => true }
  
  has_many    :payments,        :class_name => 'Payment',           :dependent => :destroy
  
  attr_accessible :name, :description, :profile, :fund_type, :merchant_name, :merchant_phone_number, 
                  :merchant_street_address, :merchant_postal_code, :merchant_date_of_birth
  attr_accessor   :associated_balanced_account

  mount_uploader :give_code, GiveCodeUploader

  def to_param
    self.uid.parameterize
  end

  # ----- Validations ----- #

  validates_presence_of :uid, :name, :description
  validates             :fund_type, :inclusion => { :in => %w(business person), :message => "%{value} is not valid" }
  validate              :create_associated_balanced_account, :on => :create, :unless => Proc.new { self.balanced_uri.present? }
                        
  # ----- Callbacks ----- #    

  before_validation :generate_and_assign_uid,       :on => :create, :unless => Proc.new { self.uid.present? }
  after_commit      :generate_and_upload_give_code, :on => :create, :if => Proc.new { not give_code? }
  #TODO: update givecode if necessary  
    
  # ----- Member Methods ----- #

  def associated_balanced_account
    if @associated_balanced_account.present?
      @associated_balanced_account
    else
      Rails.logger.debug "External call: Finding Merchant Account"
      @associated_balanced_account = Balanced::Account.find(self.balanced_uri)
    end
  end

  def generate_and_upload_give_code
    temp_dir = Rails.root.join('tmp')
    Dir.mkdir(temp_dir) unless Dir.exists?(temp_dir) # creates temp directory in heroku, which is not automatically created
    give_code_image_tempfile = Tempfile.new(["give_code_#{self.uid.to_s}", '.png'], 'tmp', :encoding => 'ascii-8bit')
    generated_code_image = IMGKit.new(Rails.application.routes.url_helpers.give_code_html_fund_url(:id => self.uid, :host => ENV['HOST'], :format => :png), :quality => 50, :height => 700, :width => 600, :'disable-smart-width' => true, :zoom => 1).to_img(:png)
    give_code_image_tempfile.write(generated_code_image)
    give_code_image_tempfile.flush
    self.give_code = give_code_image_tempfile
    self.save
    give_code_image_tempfile.unlink
  end

  # ----- Class Methods ----- #
  
  # ----- Protected Methods ----- #
  protected

  def create_associated_balanced_account
    Rails.logger.debug "External call: Creating Balanced Payments Account"
    @associated_balanced_account = Balanced::Marketplace.my_marketplace.create_account(:name => self.name)
    begin    
      merchant_data = { :type => self.fund_type,
                        :name => self.merchant_name,
                        :dob => self.merchant_date_of_birth,
                        :phone_number => self.merchant_phone_number,
                        :street_address => self.merchant_street_address,
                        :postal_code => self.merchant_postal_code }
      Rails.logger.debug "External call: Promoting Balanced Payment Account to Merchant Account"
      @associated_balanced_account.promote_to_merchant(merchant_data)
      self.balanced_uri = @associated_balanced_account.uri
    rescue Balanced::MoreInformationRequired => error
      # could not identify this account.
      puts 'redirect merchant to: ' + error.redirect_uri
      errors.add(:balanced_uri, "could not authorize merchant account")
    rescue Balanced::Error => error
      # TODO: handle 400 and 409 exceptions as required
      errors.add(:balanced_uri, "error trying to authorize merchant account")
      raise
    end
  end

  def generate_and_assign_uid
    self.uid = loop do
      random_uid = 'f_' + SecureRandom.hex(4).to_s
      break random_uid unless self.class.where(uid: random_uid).exists?
    end
  end
  
end
