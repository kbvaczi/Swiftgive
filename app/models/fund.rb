class Fund < ActiveRecord::Base

  # ----- Table Setup ----- #

  self.table_name = 'funds'
  
  has_many    :memberships,     :class_name => 'Funds::Membership', :foreign_key => :fund_id,  :dependent => :destroy
  has_many    :members,         :class_name => "Account",           :through => :memberships,  :source => :member
  has_many    :ownerships,      :class_name => 'Funds::Membership', :foreign_key => :fund_id,  :conditions => { :is_owner => true }  
  has_many    :owners,          :class_name => "Account",           :through => :ownerships,   :source => :member
  has_one     :creatorship,     :class_name => 'Funds::Membership', :foreign_key => :fund_id,  :conditions => { :is_creator => true, :is_owner => true }  
  has_one     :creator,         :class_name => "Account",           :through => :creatorship,  :source => :member

  has_one     :bank_account,    :class_name => 'BankAccount',       :conditions => { :is_active => true }
  
  has_many    :payments,        :class_name => 'Payment',           :dependent => :destroy
  
  attr_accessible :name, :description, :profile, :fund_type,
                  :street_address, :city, :state, :postal_code, 
                  :creator_info, :business_name, :business_ein, :business_phone_number
                  
  attr_accessor   :associated_balanced_customer, :creator_info

  mount_uploader :give_code, GiveCodeUploader

  def to_param
    self.uid.parameterize
  end

  # ----- Validations ----- #

  validates_presence_of :uid, :name, :description
  validates             :fund_type, :inclusion => { :in => %w(business person), :message => "%{value} is not valid" }
  validate              :create_associated_balanced_customer, :on => :create, :unless => Proc.new { self.balanced_uri.present? }
                        
  # ----- Callbacks ----- #    

  before_validation :generate_and_assign_uid,       :on => :create, :unless => Proc.new { self.uid.present? }
  before_validation :get_creator_info,              :on => :create, :unless => Proc.new { self.creator_info.present? }
  before_create     :set_commission_percent
  after_commit      :generate_and_upload_give_code, :on => :create, :if => Proc.new { not give_code? }
  #TODO: update givecode if necessary  
    
  # ----- Member Methods ----- #

  def balance
    self.payments.credit_outstanding.sum(:amount_to_receiver_in_cents)
  end

  def is_personal_fund?
    self.fund_type == 'person'
  end

  def is_business_fund?
    self.fund_type == 'business'
  end

  def associated_balanced_customer
    if @associated_balanced_customer.present?
      @associated_balanced_customer
    else
      Rails.logger.debug "External call: Finding Merchant Account"
      @associated_balanced_customer = Balanced::Account.find(self.balanced_uri)
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

  def get_creator_info
    self.creator_info = { :full_name  => self.creator.full_name,
                          :date_of_birth => self.creator.date_of_birth,
                          :street_address => self.creator.street_address,
                          :city => self.creator.city,
                          :state => self.creator.state,
                          :postal_code => self.creator.postal_code,
                          :country => self.creator.country }
    self.creator_name = self.creator_info[:full_name]
    if self.fund_type == 'person'
      self.street_address = self.creator_info[:street_address]
      self.city = self.creator_info[:city]
      self.state = self.creator_info[:state]
      self.postal_code = self.creator_info[:postal_code]
    end
    Rails.logger.debug self.creator_info
    Rails.logger.debug self.creator_info[:street_address]
  end

  def set_commission_percent
    #TODO: global variable for determining default commission without re-pushing
    self.commission_percent = 0.05
  end

  def create_associated_balanced_customer
    begin
      Rails.logger.debug "External call: Creating Balanced Payments Customer"
      @associated_balanced_customer = Balanced::Marketplace.my_marketplace.create_customer(self.formatted_balanced_customer_info)
      if @associated_balanced_customer.present?
        self.balanced_uri = @associated_balanced_customer.uri
      else
        errors.add(:balanced_uri, 'Error...')
      end
    rescue Balanced::Error => error
      Rails.logger.info("ERROR CREATING BALANCED CUSTOMER: #{error.message}")
      errors.add(:balanced_uri, error.message)
    end
  end

  def formatted_balanced_customer_info
    if self.fund_type == 'business'     
      business_info = { :ein => self.business_ein,
                        :business_name => self.business_name,
                        :phone => self.business_phone_number }                          
    else
      business_info = {}
    end
    address = { :line1 => self.street_address,
                :city  => self.city,
                :state => self.state,
                :postal_code => self.postal_code }
    formatted_balanced_customer_info = { :name => self.creator_info[:full_name],
                                         :dob => self.creator_info[:date_of_birth],
                                         :address => address }.merge(business_info)
  end

  def generate_and_assign_uid
    self.uid = loop do
      random_uid = 'f_' + SecureRandom.hex(4).to_s
      break random_uid unless self.class.where(uid: random_uid).exists?
    end
  end
  
end
