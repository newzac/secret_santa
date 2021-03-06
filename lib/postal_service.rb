require 'rest-client'

module ElfMailer
  class PostalService

    # #
    # Posts the email message and payload to the configured mailer url
    # When the boolean +DEBUG+ environment variable is set it prints the
    # messsage subject and email to stdout instead of sending
    # Params:
    # +email_info+ is hash of email configuration info including
    #   :mailer_url - string - Mailer provider url to post the message info to
    #   :from_name - string - the name to provide as the from name
    #   :from_address - string - the email address to set as the from email
    #   :to_address - string - the email address to send the email to
    #   :subject - string - the subject of the email
    #   :message - string - the message body for the email

    def self.send_message(email_info)
      if ENV['DEBUG']
        puts email_info[:subject]
        puts email_info[:message]
      else
        RestClient::Request.execute(
          :url => ENV['mailer_url'],
          :method => :post,
          :payload => {
            :from => "#{email_info[:from_name]} #{email_info[:from_address]}",
            :to => email_info[:to_address],
            :subject => email_info[:subject],
            :text => email_info[:message]
          },
          :verify_ssl => true
        )
      end
    end

    # #
    # Generates and returns the message body to be used in the mailer elf email
    # Params:
    # +secret_santa+ - string - the name of the person recieving the email
    # +person+ - string - the person that the secret santa has been matched to
    # +budget+ - string - the gift giving budget, the default is $25
    # +additional_message+ - string - any additional text that you would like to add in the message

    def self.form_message(secret_santa, person, budget="$25", additional_message="")
      <<-EOF
      Hello #{secret_santa},
      I'm your friendly Secret Santa Bot writing to tell you that I have your Secret Santa match.
      You are #{person}'s Secret Santa.
      #{"\n      " + additional_message + "\n" if additional_message.length > 0}
      This year please keep the gift buying to around #{budget}.

      Sincerely,

      #{ENV['from_name']}


      If something seems wrong with this message or if you believe that you received this message in error, please let #{ENV['contact_name']} know.
      They can be reached at #{ENV['contact_email']}
      EOF
    end
  end
end
