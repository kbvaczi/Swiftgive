class Fund < ActiveRecord::Base

  # ----- Table Setup ----- #

  self.table_name = 'funds'
  
  has_many    :memberships,     :class_name => 'Funds::Membership', :foreign_key => :fund_id,  :dependent => :destroy,  :conditions => { :is_owner => false }
  has_many    :members,         :class_name => "Account",           :through => :memberships,  :source => :member
  
  has_many    :ownerships,      :class_name => 'Funds::Membership', :foreign_key => :fund_id,  :dependent => :destroy,  :conditions => { :is_owner => true }  
  has_many    :owners,          :class_name => "Account",           :through => :ownerships,   :source => :member
  
  has_one     :creatorship,     :class_name => 'Funds::Membership', :foreign_key => :fund_id,  :dependent => :destroy,  :conditions => { :is_creator => true, :is_owner => true }  
  has_one     :creator,         :class_name => "Account",           :through => :creatorship,  :source => :member
  
  has_many    :payments,        :class_name => 'Payment',           :dependent => :destroy
  
  attr_accessible :name, :description, :profile, :fund_type,
                  :city, :state, :creator_info, :business_name
                  
  attr_accessor   :creator_info

  mount_uploader :give_code, GiveCodeUploader

  def to_param
    self.uid.parameterize
  end

  # ----- Validations ----- #

  validates_presence_of :uid, :name, :description
  validates             :fund_type, :inclusion => { :in => %w(business person), :message => "%{value} is not valid" }
  validates             :name, :format => { :with => /\A[\s\w\d().'!?]+\z/, :message => "No special characters" }
  validates_presence_of :business_name, :if => Proc.new { self.fund_type == 'business' }
                        
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
    self.payments.last(10)
  end

  def is_personal_fund?
    self.fund_type == 'person'
  end

  def is_business_fund?
    self.fund_type == 'business'
  end

  def generate_and_upload_give_code
    temp_dir = Rails.root.join('tmp')
    Dir.mkdir(temp_dir) unless Dir.exists?(temp_dir) # creates temp directory in heroku, which is not automatically created
    give_code_image_tempfile = Tempfile.new(["give_code_#{self.uid.to_s}", '.png'], 'tmp', :encoding => 'ascii-8bit')
    
    code_url  = Rails.application.routes.url_helpers.new_payment_url(:fund_uid => self.uid, :host => ENV['HOST'])
    code_html = ApplicationController.new.render_to_string :partial =>'funds/give_codes/give_code', :locals => {:message => code_url, :width => 3000}
    code_image_blob = IMGKit.new(code_html, :quality => 50, :height => 3600, :width => 3000, :zoom => 1).to_img(:png)

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
    self.creator_info = { :full_name  => self.creator.full_name,
                          :city => self.creator.city,
                          :state => self.creator.state }
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
