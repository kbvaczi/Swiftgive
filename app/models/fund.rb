class Fund < ActiveRecord::Base

  # ----- Table Setup ----- #

  self.table_name = 'funds'
    
  has_many    :memberships,     :class_name => 'Funds::Membership', :foreign_key => :fund_id, :dependent => :destroy
  has_many    :members,         :class_name => "User",              :through => :memberships, :source => :member
  has_many    :ownerships,      :class_name => 'Funds::Membership', :foreign_key => :fund_id, :conditions => {:is_owner => true}  
  has_many    :owners,          :class_name => "User",              :through => :ownerships,  :source => :member
  
  has_many    :bank_accounts,   :class_name => 'BankAccount',       :dependent => :destroy
  
  has_many    :payments,        :class_name => 'Payment',    :dependent => :destroy
  
  attr_accessible :name, :description, :profile

  mount_uploader :give_code, GiveCodeUploader

  def to_param
    self.uid.parameterize
  end

  # ----- Validations ----- #

  validates_presence_of :uid, :name, :description
                        
  # ----- Callbacks ----- #    

  before_validation :generate_and_assign_uid, :on => :create
  after_commit :generate_and_upload_give_code, :on => :create, :if => Proc.new { not give_code? }
    
  # ----- Member Methods ----- #

  def generate_and_upload_give_code
    temp_dir = Rails.root.join('tmp')
    Dir.mkdir(temp_dir) unless Dir.exists?(temp_dir)
    file = Tempfile.new(["give_code_#{self.uid.to_s}", '.png'], 'tmp', :encoding => 'ascii-8bit')
    generated_code_image = IMGKit.new(Rails.application.routes.url_helpers.give_code_html_fund_url(:id => self.uid, :host => ENV['HOST']), :quality => 50, :height => 700, :width => 600, :'disable-smart-width' => true, :zoom => 1).to_img(:png)
    file.write(generated_code_image)
    file.flush
    self.give_code = file
    self.save
    file.unlink
  end

  # ----- Class Methods ----- #
  
  # ----- Protected Methods ----- #
  protected

  def generate_and_assign_uid
    self.uid = loop do
      random_uid = 'f_' + SecureRandom.hex(3)
      break random_uid unless User.where(uid: random_uid).exists?
    end
  end
  
end
