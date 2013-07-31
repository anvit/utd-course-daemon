require 'rubygems'
require 'daemons'
require 'mechanize'
require 'gmail'

a = Mechanize.new

Daemons.run_proc('myproc.rb') do
  loop do

    page = a.get('http://coursebook.utdallas.edu/cs6348.001.13f')                 #Courss page
    da = page.parser.xpath("//div[@class='section-detail']/table/tr[3]/td").text  #xpath for the block containing available seats status
    da_stat = /(Available Seats): .../.match(da)                                  
    count_da = da_stat[0][-3..-1].to_i                                            #Number of open seats
    if(da =~ /(Section Status: )(OPEN)/ || count_da>0 )                           #If section status is open or the number of seats is greater than 0
      gmail = Gmail.new('user', 'pass')                                           #Email account for sending mails from the daemon
      email = gmail.generate_message do
        to "mymail@gmail.com"                                                     #Target mail id
        subject "Coursename"
        body "Coursename:#{da}"
      end
      gmail.deliver(email)
      gmail.logout
    end

    File.open("Ruby_course_daemon.log", 'w') {|f| f.write("#{Time.now()}" ) }   #Log last run time to file
    sleep(600)                                                                  #Sleep 10 mins
  
  end
end
