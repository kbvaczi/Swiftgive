class Fund < ActiveRecord::Base

  # ----- Table Setup ----- #

  self.table_name = 'funds'
  
  has_many    :memberships,     :class_name => 'Funds::Membership', :foreign_key => :fund_id,  :dependent => :destroy,  :conditions => { :is_owner => false }
  has_many    :members,         :class_name => "User",              :through => :memberships,  :source => :member
  
  has_many    :ownerships,      :class_name => 'Funds::Membership', :foreign_key => :fund_id,  :dependent => :destroy,  :conditions => { :is_owner => true }  
  has_many    :owners,          :class_name => "User",              :through => :ownerships,   :source => :member
  
  has_one     :creatorship,     :class_name => 'Funds::Membership', :foreign_key => :fund_id,  :dependent => :destroy,  :conditions => { :is_creator => true, :is_owner => true }  
  has_one     :creator,         :class_name => "User",              :through => :creatorship,  :source => :member
  
  has_many    :payments,        :class_name => 'Payment',           :dependent => :destroy
  
  attr_accessible :name, :description, :profile, :fund_type,
                  :city, :state, :creator_info, :receiver_name, :receiver_email
                  
  attr_accessor   :creator_info

  mount_uploader :give_code, GiveCodeUploader

  def to_param
    self.uid.parameterize
  end

  # ----- Validations ----- #

  validates_presence_of :uid, :name, :description
  validates             :fund_type, :inclusion => { :in => %w(business person third_party), :message => "%{value} is not valid" }
  validates             :name, :length => { :minimum => 10, :maximum => 50 }
  validates             :description, :length => { :minimum => 10, :maximum => 250 }
  validates_presence_of :receiver_name, :receiver_email, :unless => Proc.new { self.is_personal_fund? }
  validates             :receiver_email, :email => true, :unless => Proc.new { self.is_personal_fund? }
                        
  # ----- Callbacks ----- #    

  before_validation :generate_and_assign_uid,       :on => :create, :unless => Proc.new { self.uid.present? }
  before_validation :get_creator_info,              :on => :create, :unless => Proc.new { self.creator_info.present? }
  after_commit      :generate_and_upload_give_code, :on => :create, :unless => Proc.new { self.give_code.present? }
  # TODO: update givecode if necessary
    
  # ----- Member Methods ----- #

  def number_payments_today
    self.payments.where('created_at > ?', Time.zone.now.beginning_of_day).count
  end

  def amount_payments_today_in_cents
    self.payments.where('created_at > ?', Time.zone.now.beginning_of_day).sum(:amount_in_cents)
  end

  def number_payments_this_month
    self.payments.where('created_at > ?', Time.zone.now.beginning_of_month).count
  end

  def amount_payments_this_month_in_cents
    self.payments.where('created_at > ?', Time.zone.now.beginning_of_month).sum(:amount_in_cents)
  end

  def number_payments_this_year
    self.payments.where('created_at > ?', Time.zone.now.beginning_of_year).count
  end

  def amount_payments_this_year_in_cents
    self.payments.where('created_at > ?', Time.zone.now.beginning_of_year).sum(:amount_in_cents)
  end

  def number_payments
    self.payments.count
  end

  def amount_payments_in_cents
    self.payments.sum(:amount_in_cents)
  end

  def recent_payments
    self.payments.last(10).reverse
  end

  def is_personal_fund?
    self.fund_type == 'person'
  end

  def is_business_fund?
    self.fund_type == 'business'
  end

  def is_third_party_fund?
    self.fund_type == 'third_party'
  end

  def generate_and_upload_give_code
    temp_dir = Rails.root.join('tmp')
    Dir.mkdir(temp_dir) unless Dir.exists?(temp_dir) # creates temp directory in heroku, which is not automatically created
    give_code_image_tempfile = Tempfile.new(["give_code_#{self.uid.to_s}", '.pdf'], 'tmp', :encoding => 'ascii-8bit')
    
    code_url  = Rails.application.routes.url_helpers.new_payment_url(:fund_uid => self.uid, :host => ENV['HOST'])
    code_html = ApplicationController.new.render_to_string :partial =>'funds/give_codes/give_code', :locals => {:message => code_url, :width => 513}
    code_image_blob = PDFKit.new(code_html, { :'page-height'    => '263pt', 
                                              :'page-width'     => '250pt', 
                                              :'margin-top'     => '0', 
                                              :'margin-bottom'  => '0',
                                              :'margin-left'    => '0',
                                              :'margin-right'   => '0'}).to_pdf
    
    #we switched to pdf vector images so line below is no longer valid
    #code_image_blob = IMGKit.new(code_html, :quality => 50, :height => 3600, :width => 3000, :zoom => 1).to_img(:png)

    give_code_image_tempfile.write(code_image_blob)
    give_code_image_tempfile.flush
    
    self.give_code = give_code_image_tempfile
    self.save
    
    give_code_image_tempfile.unlink
  end

  # ----- Class Methods ----- #
  
  # ----- Protected Methods ----- #
  protected

  def get_creator_info
    creator_account = self.creator.account
    self.creator_info = { :full_name  => creator_account.full_name,
                          :city => creator_account.city,
                          :state => creator_account.state }
    self.creator_name = self.creator_info[:full_name]
    self.city = self.creator_info[:city]
    self.state = self.creator_info[:state]
  end

  def generate_and_assign_uid
    self.uid = loop do
      random_uid = 'f_' + SecureRandom.hex(4).to_s
      break random_uid unless self.class.where(uid: random_uid).exists?
    end
  end
  
end
