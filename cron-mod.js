const connections = require('./modules').connections
const cron = require('./modules').cron
const files = require('./modules').sqls
const request = require('request')
const dlog=require("./daily_log.js");
const routes = require('./modules').routes
const nativeFunctions = require('./modules').nativeFunctions
const functions = require('./modules').functions
const async = require("async");

exports.schedule=cron.schedule('00 08 * * *',()=>{
//exports.schedule=cron.schedule('12 15 * * *',()=>{
  var d = new Date();
  var day = d.toLocaleDateString();
  var dat=d.getDate();
  var mon= d.getMonth()+1;
  var yr = d.getFullYear();
  var tdat=d.getDate()-1;
  var todaydate=mon+'/'+dat+'/'+yr;
  var fixdate=mon+'/'+1+'/'+yr;
  var tabledate=tdat+'/'+mon+'/'+yr;
  var tablemonth=mon-1+'-'+yr;
  if (fixdate==todaydate) {

connections.scm_public.query(files.email,function(errs,result1,fields)
{
  connections.scm_public.query(files.onemonthmc,function(errs,result,fields)
{
  if(errs) throw err;
  console.log("connected");
var frmid='';
var toid='';
var bccid='';
var ccid='';
var passcode='';
  for(var j=0;j<result1.length;j++)
  {
    frmid=result1[j].fromid
    toid=result1[j].toid
    bccid=result1[j].bccid
    ccid=result1[j].ccid
    passcode=result1[j].passcode

  }

  var nodemailer = require('nodemailer');
console.log(frmid);
console.log(passcode);

  var transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: frmid,
    pass: passcode
  }
});
//html string that will be send to browser
var table =''; //to store html table
var date='';

//create html table with data from res.
console.log("month : "+tablemonth);
   for(var i=0; i<result.length; i++){
	   
	   var sugCogsPer ='';
	   var optCogsPer ='';
	   var pharCogsPer ='';
	   var mcCogsPer ='';
	   var sugCogsPerColr ='';
	   var optCogsPerColr ='';
	   var pharCogsPerColr ='';
	   var mcCogsPerColr ='';
	   
	   sugCogsPer = result[i].surgery_cogs_perc;
	   optCogsPer = result[i].optical_cogs_perc;
	   pharCogsPer = result[i].pharmacy_cogs_perc;
	   mcCogsPer = result[i].Consump;
	   
	   if(sugCogsPer!=null){ sugCogsPer =sugCogsPer.replace("%", "");}
	   if(optCogsPer!=null){  optCogsPer =optCogsPer.replace("%", "");}
	   if(pharCogsPer!=null){  pharCogsPer =pharCogsPer.replace("%", "");}
	   if(mcCogsPer!=null){  mcCogsPer =mcCogsPer.replace("%", "");}
	   
	   if(sugCogsPer >15){
			sugCogsPerColr = 'background-color:red'; 
		}

		if(pharCogsPer >65){
			pharCogsPerColr = 'background-color:red'; 
		}

		if(optCogsPer >40){
			optCogsPerColr = 'background-color:red'; 
		}

		

         

     table +='<tr align="right"><td>'+ result[i].entity +'</td><td>'+ result[i].branch +'</td><td>'+result[i].surgery_revenue+'</td> <td>'+ result[i].optical_revenue+'</td> <td>'+result[i].pharmacy_revenue+'</td> <td>'+result[i].mtd_revenue+'</td> <td style="background-color:#FFFF33">'+result[i].surgery_revenue_perc+'</td> <td style="background-color:#FFFF33"> '+result[i].opticals_revenue_perc +'</td><td style="background-color:#FFFF33">'+result[i].pharmacy_revenue_perc +'</td> <td>'+result[i].surgery_cogs +'</td> <td>'+result[i].opticals_cogs+'</td><td>'+result[i].pharmacy_cogs+'</td><td>'+result[i].mtd_cogs+'</td><td style="'+sugCogsPerColr+'">'+result[i].surgery_cogs_perc+'</td><td style="'+optCogsPerColr+'">'+result[i].optical_cogs_perc+'</td><td style="'+pharCogsPerColr+'">'+result[i].pharmacy_cogs_perc+'</td><td>'+result[i].Consump+'</td>  </tr>';
date =result[i].today_date;

   }

   table ='<html><body><table border="0"><tr><th colspan="17">Revenue vs Cogs '+tablemonth+' </th></tr><tr><th></th><th></th><th colspan ="4">Revenue</th><th colspan="3" style="background-color:#FFFF33">Revenue Contribution</th><th colspan="4">COGS</th><th colspan="3">COGS %</th><th>Material</th></tr><tr><th>Entity</th><th>Branch</th><th>Surgery</th><th>Opticals</th><th>Pharmacy</th><th>MTD</th> <th style="background-color:#FFFF33">Surgery</th> <th style="background-color:#FFFF33">Opticals</th> <th style="background-color:#FFFF33">Pharmacy</th><th>Surgery</th><th>Opticals</th><th>Pharmacy</th> <th>MTD</th> <th style="background-color:#FFFF33">Surgery</th><th style="background-color:#FFFF33">Opticals</th><th style="background-color:#FFFF33">Pharmacy</th><th style="background-color:#9ACD32">Consump %</th> </tr>'+ table +' </table> <br><p>Dear SCH Team,</p><p>This is top level data on Revenue Mix % & COGs % for each category.</p> <br> <p>Please use this data to:</p> <ol type="1"> <li>Immediately address consumption entry lags on daily basis</li><li>Review individual Surgery/Optical/Pharmacy COGs% variance & compare best ones in your regions & to push implement alternates.</li><li>Final COGs will be after adjusting Credit notes on Optical lens/Drugs turnover discounts & adjustments to old payables/provisions.</li> </ol> <p>For detailed information on your centres please Login into the application <a href="https://app.carehis.com">https://app.carehis.com</a>  using your login ID</p> <br><ol type="1"><li>For Revenue details: check out Revenue report & Item wise sales report.</li><li>For COGs details: check out Cost of Goods Sold report.</li></ol><br><b>Note: This report is auto generated, please do not reply.</b> <br><p>For any corrections, please drop a mail to  <a href="mailto:helpdesk@dragarwal.com">helpdesk@dragarwal.com</a>. </p> <br><p>Regards,</p><p>Dr.Agarwal IT Team</p> </body> </html> ';
//console.log(table);

let mailOptions={
  from: frmid,
    to:toid,
  bcc:bccid,
  cc:ccid,
  subject: 'Revenue vs Cogs as on '+tablemonth,
  html: table
};

transporter.sendMail(mailOptions, function(error, info){
  if (error) {
    console.log(error);
  } else {
    console.log('Email sent: ' + info.response);
  }
});

})
})


  }

  else {
    connections.scm_public.query(files.email,function(errs,result1,fields)
    {
      connections.scm_public.query(files.materialcals,function(errs,result,fields)
    {
      if(errs) throw err;
      console.log("connected");
    var frmid='';
    var toid='';
    var bccid='';
    var ccid='';
    var passcode='';
      for(var j=0;j<result1.length;j++)
      {
        frmid=result1[j].fromid
        toid=result1[j].toid
        bccid=result1[j].bccid
        ccid=result1[j].ccid
        passcode=result1[j].passcode
      }

      var nodemailer = require('nodemailer');
    // console.log(frmid);
    // console.log(passcode);

      var transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: frmid,
        pass: passcode
      }
    });
    //html string that will be send to browser
    var table =''; //to store html table
    var date='';

    //create html table with data from res.

       for(var i=0; i<result.length; i++){
		   
		   
			 var sugCogsPer ='';
			   var optCogsPer ='';
			   var pharCogsPer ='';
			   var mcCogsPer ='';
			   var sugCogsPerColr ='';
			   var optCogsPerColr ='';
			   var pharCogsPerColr ='';
			   var mcCogsPerColr ='';
			   
			   sugCogsPer = result[i].surgery_cogs_perc;
			   optCogsPer = result[i].optical_cogs_perc;
			   pharCogsPer = result[i].pharmacy_cogs_perc;
			   mcCogsPer = result[i].Consump;
			   
			   if(sugCogsPer!=null){ sugCogsPer =sugCogsPer.replace("%", "");}
			   if(optCogsPer!=null){  optCogsPer =optCogsPer.replace("%", "");}
			   if(pharCogsPer!=null){  pharCogsPer =pharCogsPer.replace("%", "");}
			   if(mcCogsPer!=null){  mcCogsPer =mcCogsPer.replace("%", "");}
			   
			   /*if(sugCogsPer >=11 && sugCogsPer <=13){
				   sugCogsPerColr = 'background-color:yellow'; 
			   }else if(sugCogsPer <11){
				   sugCogsPerColr = 'background-color:green'; 
			   }else{
				   sugCogsPerColr = 'background-color:red'; 
			   } 
			   
			   if(pharCogsPer >=55 && pharCogsPer <=60){
				   pharCogsPerColr = 'background-color:yellow'; 
			   }else if(pharCogsPer <55){
				   pharCogsPerColr = 'background-color:green'; 
			   }else{
				   pharCogsPerColr = 'background-color:red'; 
			   }
			   
			   if(optCogsPer >=30 && optCogsPer <=35){
				   optCogsPerColr = 'background-color:yellow'; 
			   }else if(optCogsPer <30){
				   optCogsPerColr = 'background-color:green'; 
			   }else{
				   optCogsPerColr = 'background-color:red'; 
			   }
			   
			   if(mcCogsPer >=21 && mcCogsPer <=23){
				   mcCogsPerColr = 'background-color:yellow'; 
			   }else if(mcCogsPer <21){
				   mcCogsPerColr = 'background-color:green'; 
			   }else{
				   mcCogsPerColr = 'background-color:red'; 
			   }*/
			   
				if(sugCogsPer >15){
					sugCogsPerColr = 'background-color:red'; 
				}

				if(pharCogsPer >65){
					pharCogsPerColr = 'background-color:red'; 
				}

				if(optCogsPer >40){
					optCogsPerColr = 'background-color:red'; 
				}

				


         table +='<tr align="right"><td>'+ result[i].entity +'</td><td>'+ result[i].branch +'</td><td>'+result[i].surgery_revenue+'</td> <td>'+ result[i].optical_revenue+'</td> <td>'+result[i].pharmacy_revenue+'</td> <td>'+result[i].mtd_revenue+'</td> <td style="background-color:#FFFF33">'+result[i].surgery_revenue_perc+'</td> <td style="background-color:#FFFF33"> '+result[i].opticals_revenue_perc +'</td><td style="background-color:#FFFF33">'+result[i].pharmacy_revenue_perc +'</td> <td>'+result[i].surgery_cogs +'</td> <td>'+result[i].opticals_cogs+'</td><td>'+result[i].pharmacy_cogs+'</td><td>'+result[i].mtd_cogs+'</td><td style="'+sugCogsPerColr+'">'+result[i].surgery_cogs_perc+'</td><td style="'+optCogsPerColr+'">'+result[i].optical_cogs_perc+'</td><td style="'+pharCogsPerColr+'">'+result[i].pharmacy_cogs_perc+'</td><td>'+result[i].Consump+'</td>  </tr>';
    date =result[i].today_date;

       }

       table ='<html><body><p>Dear SCH Team,</p><p>This is top level data on Revenue Mix % & COGs % for each category.</p> <br> <table border="0"><tr><th colspan="17">Revenue vs Cogs '+date+' </th></tr><tr><th></th><th></th><th colspan ="4">Revenue</th><th colspan="3" style="background-color:#FFFF33">Revenue Contribution</th><th colspan="4">COGS</th><th colspan="3">COGS %</th><th>Material</th></tr><tr><th>Entity</th><th>Branch</th><th>Surgery</th><th>Opticals</th><th>Pharmacy</th><th>MTD</th> <th style="background-color:#FFFF33">Surgery</th> <th style="background-color:#FFFF33">Opticals</th> <th style="background-color:#FFFF33">Pharmacy</th><th>Surgery</th><th>Opticals</th><th>Pharmacy</th> <th>MTD</th> <th style="background-color:#FFFF33">Surgery</th><th style="background-color:#FFFF33">Opticals</th><th style="background-color:#FFFF33">Pharmacy</th><th style="background-color:#9ACD32">Consump %</th> </tr>'+ table +' </table> <br><p>Please use this data to:</p> <ol type="1"> <li>Immediately address consumption entry lags on daily basis</li><li>Review individual Surgery/Optical/Pharmacy COGs% variance & compare best ones in your regions & to push implement alternates.</li><li>Final COGs will be after adjusting Credit notes on Optical lens/Drugs turnover discounts & adjustments to old payables/provisions.</li> </ol> <p>For detailed information on your centres please Login into the application <a href="https://app.carehis.com">https://app.carehis.com</a>  using your login ID</p> <br><ol type="1"><li>For Revenue details: check out Revenue report & Item wise sales report.</li><li>For COGs details: check out Cost of Goods Sold report.</li></ol><br><b>Note: This report is auto generated, please do not reply.</b> <br><p>For any corrections, please drop a mail to  <a href="mailto:helpdesk@dragarwal.com">helpdesk@dragarwal.com</a>. </p> <br><p>Regards,</p><p>Dr.Agarwal IT Team</p> </body> </html> ';
    //console.log(table);

    let mailOptions={
      from: frmid,
        to:toid,
      bcc:bccid,
      cc:ccid,
      subject: 'Revenue vs Cogs as on '+tabledate,
      html: table
    };

    transporter.sendMail(mailOptions, function(error, info){
      if (error) {
        console.log(error);
      } else {
        console.log('Email sent: ' + info.response);
      }
    });

    })
    })

  }

})

// exports.schedule=cron.schedule('08 15 * * *',() =>{
//   connections.scm_root.query(files.materialcost,(errs)=> {
//       if (errs) console.error(errs)
//     console.log('connected to write');
//     console.log('generated materialcost');
//
//      let sql = `SELECT * FROM materialcost`;
//    connections.scm_public.query(sql,function(errs,result,fields)
//  {
// if (errs) throw err;
// console.log("connected to readonly");
// // const Excel = require('exceljs');
// //
// // const options = {
// //   filename: 'myfile.xlsx',
// //   useStyles: true,
// //   useSharedStrings: true
// // };
// //
// // const workbook = new Excel.stream.xlsx.WorkbookWriter(options);
// //
// // const worksheet = workbook.addWorksheet('my sheet');
// //
// //
// // worksheet.columns = [
// //     { header: 'Entity', key: 'entity' },
// //     { header: 'Branch', key: 'branch' },
// //     { header: 'pharmacy_revenue', key: 'pharmacy_revenue' },
// //     { header: 'optical_revenue', key: 'optical_revenue' },
// //     { header: 'surgery_revenue', key: 'surgery_revenue' },
// //     { header: 'mtd_revenue', key: 'mtd_revenue' },
// //     { header: 'pharmacy_revenue_perc', key: 'pharmacy_revenue_perc' },
// //     { header: 'opticals_revenue_perc', key: 'opticals_revenue_perc' },
// //     { header: 'surgery_revenue_perc', key: 'surgery_revenue_perc' },
// //     { header: 'pharmacy_cogs', key: 'pharmacy_cogs' },
// //       { header: 'opticals_cogs', key: 'opticals_cogs' },
// //         { header: 'surgery_cogs', key: 'surgery_cogs' },
// //         { header: 'mtd_cogs', key: 'mtd_cogs' },
// //         { header: 'pharmacy_cogs_perc', key: 'pharmacy_cogs_perc' },
// //         { header: 'opticals_cogs_perc', key: 'opticals_cogs_perc' },
// //           { header: 'surgery_cogs_perc', key: 'surgery_cogs_perc' },
// //             { header: 'MC', key: 'mc' },
// // ]
// // var data;
// //
// // Object.keys(result).forEach(function(key){
// //       var row = result[key];
// // var entity_wise=row.entity;
// // var branch_wise=row.branch;
// // var pharmacy_revenue_wise=row.pharmacy_revenue;
// // var optical_revenue_wise=row.optical_revenue;
// // var surgery_revenue_wise=row.surgery_revenue;
// // var mtd_revenue_wise=row.mtd_revenue;
// // var pharmacy_revenue_perc_wise=row.pharmacy_revenue_perc;
// // var opticals_revenue_perc_wise=row.opticals_revenue_perc;
// // var surgery_revenue_perc_wise=row.surgery_revenue_perc;
// // var pharmacy_cogs_wise=row.pharmacy_cogs;
// // var opticals_cogs_wise=row.opticals_cogs;
// // var surgery_cogs_wise=row.surgery_cogs;
// // var mtd_cogs_wise=row.mtd_cogs;
// // var pharmacy_cogs_perc_wise=row.pharmacy_cogs_perc;
// // var opticals_cogs_perc_wise=row.opticals_cogs_perc;
// // var surgery_cogs_perc_wise=row.surgery_cogs_perc;
// // var mc_wise=row.MC;
// //     data = {
// //       entity: entity_wise,
// //       branch: branch_wise,
// //       pharmacy_revenue: pharmacy_revenue_wise,
// //       optical_revenue: optical_revenue_wise,
// //       surgery_revenue: surgery_revenue_wise,
// //       mtd_revenue: mtd_revenue_wise,
// //       pharmacy_revenue_perc: pharmacy_revenue_perc_wise,
// //       opticals_revenue_perc: opticals_revenue_perc_wise,
// //       surgery_revenue_perc:surgery_revenue_perc_wise,
// //       pharmacy_cogs: pharmacy_cogs_wise,
// //       opticals_cogs : opticals_cogs_wise,
// //       surgery_cogs :surgery_cogs_wise,
// //       mtd_cogs : mtd_cogs_wise,
// //       pharmacy_cogs_perc :pharmacy_cogs_perc_wise,
// //       opticals_cogs_perc :opticals_cogs_perc_wise,
// //       surgery_cogs_perc :surgery_cogs_perc_wise,
// //       mc:mc_wise
// //     };
// //
// //
// //
// // worksheet.addRow(data).commit();
// //
// //
// //
// //
// //
// //
// // })
// //
// //
// //
// // workbook.commit().then(function() {
// //   console.log('excel file cretaed');
// // });
// //
// //
// //
//
//
//
//   var nodemailer = require('nodemailer');
//
//   var transporter = nodemailer.createTransport({
//   service: 'gmail',
//   auth: {
//     user: 'praveenraj.y@dragarwal.com',
//     pass: 'praveenrajyv22'
//   }
// });
//
//   var table =''; //to store html table
// var date='';
//   //create html table with data from res.
//      for(var i=0; i<result.length; i++){
//
//
//        table +='<tr><td>'+ result[i].entity +'</td><td>'+ result[i].branch +'</td><td>'+result[i].surgery_revenue+'</td> <td>'+ result[i].optical_revenue+'</td> <td>'+result[i].pharmacy_revenue+'</td> <td>'+result[i].mtd_revenue+'</td> <td>'+result[i].surgery_revenue_perc+'</td> <td> '+result[i].opticals_revenue_perc +'</td><td>'+result[i].pharmacy_revenue_perc +'</td> <td>'+result[i].surgery_cogs +'</td> <td>'+result[i].opticals_cogs+'</td><td>'+result[i].pharmacy_cogs+'</td><td>'+result[i].mtd_cogs+'</td><td>'+result[i].pharmacy_cogs_perc+'</td><td>'+result[i].opticals_cogs_perc+'</td><td>'+result[i].pharmacy_cogs_perc+'</td><td>'+result[i].Consump+'</td>  </tr>';
// date =result[i].today_date;
//
//      }
//
//      table ='<table border="1"><tr><th colspan="17">Revenue vs Cogs '+result.date+' </th></tr><tr><th></th><th></th><th colspan ="4">Revenue</th><th colspan="3">Revenue Contribution</th><th colspan="4">COGS</th><th colspan="3">COGS %</th><th>Material</th></tr><tr><th>Entity</th><th>Branch</th><th>Surgery</th><th>Opticals</th><th>Pharmacy</th><th>MTD</th> <th>Surgery</th> <th>Opticals</th> <th>Pharmacy</th><th>Surgery</th><th>Opticals</th><th>Pharmacy</th> <th>MTD</th> <th>Surgery</th><th>Opticals</th><th>Pharmacy</th><th>Consump %</th> </tr>'+ table +' </table>';
// //console.log(table);
//
//
// let mailOptions={
//   from: 'praveenraj.y@dragarwal.com',
//   to:'praveenraj.yv@gmail.com',
//   subject: 'Revenue vs Cogs',
// html: table
// };
//
// transporter.sendMail(mailOptions, function(error, info){
//   if (error) {
//     console.log(error);
//   } else {
//     console.log('Email sent: ' + info.response);
//   }
// });
//
//
//
//  })
//   })
// });




exports.schedule = cron.schedule('00 06 * * *', () => {
//exports.schedule = cron.schedule('53 11 * * *', () => {
    connections.ideamed.getConnection((err, con) => {
        if (err) console.log('Connection Error.')
        con.query(files.orbit_cogs_backup, (ideaerr, ideares) => {
            if (ideaerr) console.error(ideaerr)
            console.log('Connected to Ideamed.')
            console.log('Inserting Records for Cogs table.Please Wait...')
            con.beginTransaction(err => {
                if (err) console.error(err)
                ideares.forEach(record => {
                    connections.scm_root.query('insert into cogs_details set ?', record, (error) => {
                        if (error) {
                            return con.rollback(function () {
                                console.error(error)
                            });
                        }
                        con.commit(function (err) {
                            if (err) {
                                return con.rollback(function () {
                                    console.error(err)
                                });
                            }
                        });
                    })
                })
                connections.scm_root.query(files.cogsreport, (errs) => {
                    if (errs) console.error(errs)
                    console.log('Finished loading Cogs.')
                    console.log('Generated Cogs Report table.')
                })
            })
        })
    })
    connections.ideamed.getConnection((err, con) => {
        if (err) console.log('Connection Error.')
        con.query(files.revenuebackup, (ideaerr, ideares) => {
            if (ideaerr) console.error(ideaerr)
            console.log('Connected to Ideamed.')
            console.log('Inserting Records for Revenue table.Please Wait...')
            con.beginTransaction(err => {
                if (err) console.error(err)
                ideares.forEach(record => {
                    connections.scm_root.query('insert into revenue_details set ?', record, (error) => {
                        if (error) {
                            return con.rollback(function () {
                                console.error(error)
                            });
                        }
                        con.commit(function (err) {
                            if (err) {
                                return con.rollback(function () {
                                    console.error(err)
                                });
                            }
                        });
                    })
                })
                connections.scm_root.query(files.revenuereport, (errs) => {
                    if (errs) console.error(errs)
                    connections.scm_root.query(files.breakupReport, (berrs) => {
                        if (berrs) console.error(berrs)
                        console.log('Finished loading Revenue & breakup.')
                        console.log('Generated Revenue & breakup Report table.')
                    })
                })
            })
        })
    })

    
    connections.ideamed.getConnection((err, con) => {
        if (err) console.log('Connection Error.')
        con.query(files.vobbackup, (ideaerr, ideares) => {
            if (ideaerr) console.error(ideaerr)
            console.log('Connected to Ideamed.')
            console.log('Inserting Records for VOB table.Please Wait...')
            con.beginTransaction(err => {
                if (err) console.error(err)
                ideares.forEach(record => {
                    connections.scm_root.query('insert into vob set ?', record, (error) => {
                        if (error) {
                            return con.rollback(function () {
                                console.error(error)
                            });
                        }
                        con.commit(function (err) {
                            if (err) {
                                return con.rollback(function () {
                                    console.error(err)
                                });
                            }
                        });
                    })
                })
                connections.scm_root.query(files.vobreport, (errs) => {
                    if (errs) console.error(errs)
                    console.log('Finished loading VOB.')
                    console.log('Generated VOB Report table.')
                })
            })
        })
    })
	
	console.log('completed');
})



//exports.schedule = cron.schedule('45 22 * * *', () => {
//exports.schedule = cron.schedule('13 17 * * *', () => {
	exports.schedule = cron.schedule('30 04 * * *', () => {
    connections.ideamed.getConnection((err, con) => {
        if (err) console.log('Connection Error.')
        con.query(files.cogsbackup, (ideaerr, ideares) => {
            if (ideaerr) console.error(ideaerr)
            console.log('Connected to Ideamed.')
            console.log('Inserting Records for Cogs table.Please Wait...')
            con.beginTransaction(err => {
                if (err) console.error(err)
                ideares.forEach(record => {
                    connections.scm_root.query('insert into cogs_details set ?', record, (error) => {
                        if (error) {
                            return con.rollback(function () {
                                console.error(error)
                            });
                        }
                        con.commit(function (err) {
                            if (err) {
                                return con.rollback(function () {
                                    console.error(err)
                                });
                            }
                        });
                    })
                })
                
            })
			console.log('completed');
        })
    })
	
	console.log('start');
    
})







exports.schedule = cron.schedule('30 07 * * *', () => {
//exports.schedule = cron.schedule('58 10 * * *', () => {
    connections.ideamed.getConnection((err, con) => {
        if (err) console.log('Connection Error.')
        con.query(files.opdatalist, (ideaerr_op, ideares_op) => {
            if (ideaerr_op) console.error(ideaerr_op)
            console.log('Connected to Ideamed.')
            console.log('Inserting Records for opd_details.Please Wait...')
            con.beginTransaction(err => {
                if (err) console.error(err)
                ideares_op.forEach(record => {
					
					//console.log(record);
                    connections.scm_root.query('insert into op_details set ?', record, (error) => {
                        if (error) {
                            return con.rollback(function () {
                                console.error(error)
                            });
                        }
                        con.commit(function (err) {
                            if (err) {
                                return con.rollback(function () {
                                    console.error(err)
                                });
                            }
                        });
                    })
                })
               
            })
        })
    })
    console.log('completed');
})





exports.schedule = cron.schedule('00 07 * * *', () => {
//exports.schedule = cron.schedule('30 11 * * *', () => {
	var nodemailer = require('nodemailer');
	var fs  = require('fs');
	var transporter = nodemailer.createTransport({
	service: 'gmail',
	auth: {
	  user: 'misreport@dragarwal.com',
	  pass: 'MI$em@il@321'
	}
	});
	  
	let mailOptions={
		from: 'misreport@dragarwal.com',
		to:'misreport@dragarwal.com',		
		text: ''
	};
					 
					 
	/*yester day */	

	var today = new Date();
	var yesterday = new Date(today);
	yesterday.setDate(today.getDate() - 1);
	var dd = yesterday.getDate();
	var mm = yesterday.getMonth()+1; //January is 0!

	var yyyy = yesterday.getFullYear();
	if(dd<10){dd='0'+dd} if(mm<10){mm='0'+mm} 
	yesterday = yyyy+'-'+mm+'-'+dd;

	var apiurl = 'http://openexchangerates.org/api/historical/'+yesterday+'.json?app_id=74e52ac0cde843989f9c9c9d5dba2961&base=USD&symbols=TZS,UGX,GHS,ZMW,MUR,RWF,MZN,MGA,NGN,INR,KES';
	
	
		
	  /* var d = new Date();
	  var day = d.toLocaleDateString();
	  var dat=d.getDate();
	  //var mon= d.getMonth()+1;
	  var mon=("0" + (d.getMonth()+1)).slice(-2);
	  var yr = d.getFullYear();
	 // var tdat=d.getDate()-1;
	  var tdat=("0" + (d.getDate()-1)).slice(-2);
	  var yesterdaydate=yr+'-'+mon+'-'+tdat;
	  var apiurl = 'https://openexchangerates.org/api/historical/'+yesterdaydate+'.json?app_id=74e52ac0cde843989f9c9c9d5dba2961&base=USD&symbols=TZS,UGX,GHS,ZMW,MUR,RWF,MZN,MGA,NGN,INR,KES';
	  */
      /*yester day */		
	  
      //var apiurl = 'https://openexchangerates.org/api/latest.json?app_id=74e52ac0cde843989f9c9c9d5dba2961&base=USD&symbols=TZS,UGX,GHS,ZMW,MUR,RWF,MZN,MGA,NGN,INR,KES';
	  
 	  
	request(apiurl,{ json: true }, function(error, response,body) {
	if ((error) || body.hasOwnProperty("error")) {

			mailOptions.subject="Currency api error :: Api url ::"+apiurl;
			mailOptions.text=body.description;
			
			transporter.sendMail(mailOptions, function(error, info){
			  if (error) {
				console.log(error);
			  } else {
				console.log('Email sent: ' + info.response);
			  }
			});
			
			var  fileContent = {"date":yesterday,"Api url":apiurl};
			var newfileContent = Object.assign(fileContent, body);
			newfileContent = JSON.stringify(newfileContent)+'\n'; 
			let fileName = '/home/ubuntu/scmlogs/currency_api_err_'+yyyy+'-'+mm+'.txt';			
			
			fs.appendFile(fileName, newfileContent, function (err) { 
				if (err)
			console.log(err);
			else
				console.log('Append operation complete.');
			});
	}else{
		
		/*var timestamp = body.timestamp;
		var date = new Date(timestamp * 1000);
		var currency_date = date.getFullYear()+'-'+ 
		("0" + (date.getMonth() + 1)).slice(-2)+			
		'-'+("0" + (date.getDate())).slice(-2);	*/	
		for (var key in body.rates){
			var countrycode='',currencycode='',inr_amount=0,insetquery='',usd_amount=0;
			if(key!=='INR'){					
				inr_amount = (1/body.rates[key])*body.rates['INR'];
				if(key=='TZS'){
					countrycode='TZA'
				}else if(key=='UGX'){
					countrycode='UGD';
				}else if(key=='GHS'){
					countrycode='GHA';
				}else if(key=='ZMW'){
					countrycode='ZMW';
				}else if(key=='MUR'){
					countrycode='MUR';
				}else if(key=='RWF'){
					countrycode='RWD';
				}else if(key=='MZN'){
					countrycode='MZN';
				}else if(key=='MGA'){
					countrycode='MDR';
				}else if(key=='NGN'){
					countrycode='NGA';
				}else if(key=='KES'){
					countrycode='NAB';
				}					
			}else{
				countrycode=key;
				inr_amount = body.rates['INR'];
			}
			usd_amount = body.rates[key];
			currencycode = key;
			insetquery = 'insert into currency_rates set INR_rate="'+inr_amount+'",country_code="'+countrycode+'",currency_code="'+currencycode+'",currency_date="'+yesterday+'",USD_rate="'+usd_amount+'",add_date=now()';
				connections.scm_root.query(insetquery, (error1,res1) => {
					if (error1) {                            
							console.log(error1);                           
					}else{
						console.log(res1);
					}
					
				})
			
			
		}
		mailOptions.subject='Currency api success';
		mailOptions.text='Api url ::'+apiurl;
		transporter.sendMail(mailOptions, function(error, info){
			  if (error) {
				console.log(error);
			  } else {
				console.log('Email sent: ' + info.response);
			  }
			});
		console.log('inserted');
	}
})
   
    console.log('completed');
})

//collection recon
exports.schedule = cron.schedule('00 01 * * *', () => {
//exports.schedule = cron.schedule('39 11 * * *', () => {
    console.log("connected");
    connections.ideamed.getConnection((err, con) => {
    if (err) console.error('connection error');
    con.query(files.collectiondetailim, (collectionerr, collectioneres) => {
      if (collectionerr) console.error(collectionerr);
      console.log("connected to Ideamed");
      console.log('inserting in collection_detail table.please wait.....');
      con.beginTransaction(err => {
        if (err) console.error(err);
        console.log("1");
        collectioneres.forEach(records => {
          connections.scm_root.query("insert into collection_detail set ?", records, (error) => {
            if (error) {
              return con.rollback(function() {
                console.error(error)
              });
            }
          })
        })

        console.log("hit in 2");
        connections.scm_root.query("INSERT INTO collection_recon(PARENT_BRANCH,BRANCH,REGION,PAYMENT_OR_REFUND_DATE)  SELECT entity,CODE,region,date_add(curdate(),interval 1 day) FROM branches WHERE entity IN ('AEH','AHC','AHI') ORDER BY CODE ASC",(err,resdata)=>{
          if(err){
            return con.rollback(function() {
              console.error(err)
            });
          }
          else {
            con.commit(function(err) {
               if (err) {
                 return con.rollback(function() {
                   console.error(err);
                 });
               }
             })

          }

        })

        

      })

      console.log('completed');
    })
    con.release();
  })
})



exports.schedule = cron.schedule('30 09 * * *', () => {
  
  var today = new Date();
  var yesterday = new Date(today);
  yesterday.setDate(today.getDate() - 1);
  var dd = yesterday.getDate();
  var mm = yesterday.getMonth() + 1; //January is 0!
  var yyyy = yesterday.getFullYear();
  if (dd < 10) {
    dd = '0' + dd
  }
  if (mm < 10) {
    mm = '0' + mm
  }

   yesterday = yyyy + '-' + mm + '-' + dd;
//  yesterday = 2021 + '-' + '01' + '-' + '31';
  
  var filepath = '/home/ubuntu/scmlogs/collection_email_cron_' + '_' + yesterday + '.txt';
  routes.main_route_collection_mail(yesterday, (_err, _res) => {
    if (_err) {
      //console.log(_err);
      dlog.log(_err, filepath);
      dlog.cronErrEmail("Collection email not sent", _err);
    } else {

      nativeFunctions.collectionemail(_res, yesterday).then(
        (emailtemp) => {
          routes.collection_email(emailtemp, (_err1, emailres) => {
              if (_err1) {
              //console.log(_err1);
              dlog.log(_err1, filepath);
              dlog.cronErrEmail("Collection email not sent", _err2);
            } else {
			  dlog.cronEmail(emailtemp, emailres, yesterday, 6, (_err2, _res2) => {
              
                if (_err2) {
                  //console.log(_err2);
                  dlog.log(_err2, filepath);
                  dlog.cronErrEmail("Collection email not sent", _err2);

                } else {
                  //console.log(_res2);
                }
              })
            }
          })
        }
      )
    }
  })
  

})



exports.schedule = cron.schedule('45 07 * * *', () => {
//exports.schedule = cron.schedule('02 16 * * *', () => {	
	var today = new Date();
	var yesterday = new Date(today);
	yesterday.setDate(today.getDate() - 1);
	var dd = yesterday.getDate();
	var mm = yesterday.getMonth()+1; //January is 0!

	var yyyy = yesterday.getFullYear();
	if(dd<10){dd='0'+dd} if(mm<10){mm='0'+mm} 
	yesterday = yyyy+'-'+mm+'-'+dd;
    var filepath = '/home/ubuntu/scmlogs/ava_email_cron_'+'_'+yesterday+'.txt';   
	//var filepath = 'D:/git/cogs-api-new-final/ava_email_cron_'+'_'+yesterday+'.txt';   
    routes.main_route_usage_tracker_new_email(yesterday, (_err, _res) => {
                       	if(_err){
							console.log(_err);
							dlog.log(_err,filepath);	
							dlog.cronErrEmail("AVA email not sent",_err);	
						}else{
							
							nativeFunctions.avaDemoEmail(_res,yesterday).then(
							(emailtemp) => {
								routes.avaEmailList(emailtemp, (_err1, emailres) => {
									if(_err1){
										console.log(_err1);
										dlog.log(_err1,filepath);
										dlog.cronErrEmail("AVA email not sent",_err1);	
									}else{
										dlog.cronEmail(emailtemp,emailres,yesterday,1,(_err2, _res2) => {											
											if(_err2){
												    console.log(_err2);
										            dlog.log(_err2,filepath);
													dlog.cronErrEmail("AVA email not sent","error in cronEmail");	
											}else{
												 console.log(_res2);	
											}
										})
										
									}
									
								})
								 
							})
							
						}
    });
	
})




exports.schedule = cron.schedule('00 11 * * *', () => {
//exports.schedule = cron.schedule('02 16 * * *', () => {	
  var d = new Date();
  var day = d.toLocaleDateString();
  var dat=d.getDate();
  var mon= d.getMonth()+1;
  var yr = d.getFullYear();
  var today =  yr+'-'+mon+'-'+dat;
  
    if(dat==1 || dat==16){
		var filepath = '/home/ubuntu/scmlogs/inactive_cron_'+'_'+today+'.txt';   
		//var filepath = 'D:/git/cogs-api-new-final/inactive_cron_'+'_'+today+'.txt';    
		routes.main_route_inactive_user(dat, (_err,emailtemp) => {
				if(_err){
					console.log("error");
					console.log(_err);
					dlog.log(_err,filepath);	
					dlog.cronErrEmail("inactive user email not sent",_err);	
				}else{
					routes.inactiveEmailList(emailtemp, (_err1, emailres) => {
										if(_err1){
											console.log(_err1);
											dlog.log(_err1,filepath);
											dlog.cronErrEmail("inactive user email not sent",_err1);	
										}else{
											dlog.cronEmail(emailtemp,emailres,today,2,(_err2, _res2) => {							
												if(_err2){
														console.log(_err2);
														dlog.log(_err2,filepath);
														dlog.cronErrEmail("Inactive user email not sent","error in cronEmail");	
												}else{
													 console.log(_res2);	
												}
											})
											
										}
										
					})
				}      
		});
	}else{
		console.log("email not sent");
	}
 
	
})



exports.schedule = cron.schedule('15 09 * * *', () => {
//exports.schedule = cron.schedule('02 16 * * *', () => {	
	var today = new Date();
	var yesterday = new Date(today);
	yesterday.setDate(today.getDate() - 1);
	var dd = yesterday.getDate();
	var mm = yesterday.getMonth()+1; //January is 0!

	var yyyy = yesterday.getFullYear();
	if(dd<10){dd='0'+dd} if(mm<10){mm='0'+mm} 
	yesterday = yyyy+'-'+mm+'-'+dd;
    var filepath = '/home/ubuntu/scmlogs/ava_email_overseas_cron_'+'_'+yesterday+'.txt';   
	//var filepath = 'D:/git/cogs-api-new-final/ava_email_cron_'+'_'+yesterday+'.txt';   
    routes.main_route_usage_tracker_new_email(yesterday, (_err, _res) => {
                       	if(_err){
							console.log(_err);
							dlog.log(_err,filepath);	
							dlog.cronErrEmail("AVA overseas email not sent",_err);	
						}else{
							
							nativeFunctions.avaOverseasEmail(_res,yesterday).then(
							(emailtemp) => {
								routes.avaOverseasEmailList(emailtemp, (_err1, emailres) => {
									if(_err1){
										console.log(_err1);
										dlog.log(_err1,filepath);
										dlog.cronErrEmail("AVA overseas email not sent",_err1);	
									}else{
										dlog.cronEmail(emailtemp,emailres,yesterday,3,(_err2, _res2) => {											
											if(_err2){
												    console.log(_err2);
										            dlog.log(_err2,filepath);
													dlog.cronErrEmail("AVA overseas email not sent","error in cronEmail");	
											}else{
												 console.log(_res2);	
											}
										})
										
									}
									
								})
								 
							})
							
						}
    });
	
})



exports.schedule = cron.schedule('05 08 * * *', () => {
//exports.schedule = cron.schedule('05 14 * * *', () => {	
	var today = new Date();
	var yesterday = new Date(today);
	yesterday.setDate(today.getDate() - 1);
	var dd = yesterday.getDate();
	var mm = yesterday.getMonth()+1; //January is 0!

	var yyyy = yesterday.getFullYear();
	if(dd<10){dd='0'+dd} if(mm<10){mm='0'+mm} 
	yesterday = yyyy+'-'+mm+'-'+dd;
    var filepath = '/home/ubuntu/scmlogs/opd_email_cron_'+'_'+yesterday+'.txt';   
	//var filepath = 'D:/git/cogs-api-new-final/ava_email_cron_'+'_'+yesterday+'.txt';   
    routes.main_route_newopd_mail(yesterday, (_err, _res) => {
                       	if(_err){
							console.log(_err);
							dlog.log(_err,filepath);	
							dlog.cronErrEmail("New OPD email not sent",_err);	
						}else{
							
							nativeFunctions.newOPDEmail(_res,yesterday).then(
							(emailtemp) => {
								routes.opdEmailList(emailtemp, (_err1, emailres) => {
									if(_err1){
										console.log(_err1);
										dlog.log(_err1,filepath);
										dlog.cronErrEmail("New OPD email not sent",_err1);	
									}else{
										dlog.cronEmail(emailtemp,emailres,yesterday,4,(_err2, _res2) => {											
											if(_err2){
												    console.log(_err2);
										            dlog.log(_err2,filepath);
													dlog.cronErrEmail("New OPD email not sent","error in cronEmail");	
											}else{
												 console.log(_res2);	
											}
										})
										
									}
									
								})
								 
							})
							
						}
    });
	
})




// praveen validation of claim Amount
exports.schedule = cron.schedule('45 10 * * *', () => {
  var d = new Date();
  var day = d.toLocaleDateString();
  var dat = d.getDate();
  var mon = d.getMonth() + 1;
  var yr = d.getFullYear();
  var tdat = d.getDate() - 1;
  var todaydate = yr + '/' + mon + '/' + dat;
  var fixdate = yr + '/' + mon + '/' + 1;
  var tabledate = tdat + '/' + mon + '/' + yr;
  console.log("hit");
  if (fixdate == todaydate) {
    console.log('Same date');
  } else {
    connections.scm_public.query("SELECT  fromid,toid,bccid,ccid,passcode FROM email WHERE scmtype='claimamtvalid'", function(err, result1, fields) {
      if (err) throw err;
    //  console.log(result1);
      console.log("connected to mis");
      connections.ideamed.query(files.claimamountvalid, function(err, result, fields) {
        if (err) throw err;
        console.log('executed');

        var frmid = '';
        var toid = '';
        var bccid = '';
        var ccid = '';
        var passcode = '';
        for (var j = 0; j < result1.length; j++) {
          frmid = result1[j].fromid
          toid = result1[j].toid
          bccid = result1[j].bccid
          ccid = result1[j].ccid
          passcode = result1[j].passcode

        }
        var nodemailer = require('nodemailer');
        // console.log(frmid);
        // console.log(passcode);

        var transporter = nodemailer.createTransport({
          service: 'gmail',
          auth: {
            user: frmid,
            pass: passcode
          }
        });

        var table = '';
        var branch = '';
        var billno = '';
        var billdate = '';
        var revenuedate = '';
        var mrn = '';
        var payor = '';
        var billamount = '';
        var discount = '';
        var netamount = '';
        var paidamount = '';
        var billclaimamount = '';
        var servicclaimamount = '';
        var salesclaimamount = '';
        var servicedetailclaimamount = '';
        var type = '';

        for (var i = 0; i < result.length; i++) {
          branch = result[i].BRANCH;
          billno = result[i].BILLNO;
          billdate = result[i].BILLDATE;
          revenuedate = result[i].REVENUEDATE;
          mrn = result[i].MRN;
          payor = result[i].PAYOR;
          billamount = result[i].BILLAMOUNT;
          discount = result[i].DISCOUNT;
          netamount = result[i].NETAMOUNT;
          paidamount = result[i].PAIDAMOUNT;
          billclaimamount = result[i].BILLCLAIMAMOUNT;
          servicclaimamount = result[i].SERVICECLAIMAMOUNT;
          salesclaimamount = result[i].SALESCLAIMAMOUNT;
          servicedetailclaimamount = result[i].SALESDETAILCLAIMAMOUNT;
          type = result[i].TYPE;

          table += '<tr> <td >' + branch + '</td> <td>' + billno + '</td> <td>' + billdate + '</td><td>' + revenuedate + '</td> <td>' + mrn + '</td> <td>' + payor + '</td> <td>' + billamount + '</td> <td>' + discount + '</td> <td>' + netamount + '</td> <td>' + paidamount + '</td> <td>' + billclaimamount + '</td> <td>' + servicclaimamount + '</td> <td>' + salesclaimamount + '</td> <td>' + servicedetailclaimamount + '</td> <td>' + type + '</td> <td>'
        }
        table = '<html><body> <table border="1"><tr><th colspan="17">Claim amount validation as on ' + tabledate + ' </th></tr><tr><th>Branch</th><th>Bill no</th><th>Bill date</th><th>Revenue date</th> <th>Mrn</th><th>Payor</th> <th>Bill Amount</th><th>Discount</th><th>Net Amount</th><th>Paid Amount</th> <th>Bill Claim Amount</th><th>Service Claim Amount</th> <th>Sales Claim Amount</th> <th>Servicedetail Claim Amount</th><th>Type</th> </tr>' + table + ' </table> <br><b>Note: This report is auto generated, please do not reply.</b> <br><p>For any corrections, please drop a mail to  <a href="mailto:helpdesk@dragarwal.com">helpdesk@dragarwal.com</a>. </p> <br><p>Regards,</p><p>Dr.Agarwal IT Team</p> </body> </html> ';

        //console.log(table);
        let mailOptions = {
          from: frmid,
          to: toid,
          bcc: bccid,
          cc: ccid,
          subject: 'Claim Amount validation in ideamed ' + tabledate,
          html: table
        };
        transporter.sendMail(mailOptions, function(error, info) {
          if (error) {
            console.log(error);
          } else {
            console.log('Email sent: ' + info.response);
          }
        });

      })

    })
  }

})




exports.schedule = cron.schedule('15 08 * * *', () => {
//exports.schedule = cron.schedule('05 14 * * *', () => {	
	var today = new Date();
	var yesterday = new Date(today);
	yesterday.setDate(today.getDate() - 1);
	var dd = yesterday.getDate();
	var mm = yesterday.getMonth()+1; //January is 0!

	var yyyy = yesterday.getFullYear();
	if(dd<10){dd='0'+dd} if(mm<10){mm='0'+mm} 
	yesterday = yyyy+'-'+mm+'-'+dd;
    //var filepath = '/home/ubuntu/scmlogs/materialcogs_overseas_email_cron_'+'_'+yesterday+'.txt';   
	var filepath = 'D:/git/cogs-api-new-final/materialcogs_overseas_email_cron_'+'_'+yesterday+'.txt';   
    routes.materialcogs_email(yesterday, (_err, _res) => {
                       	if(_err){
							console.log(_err);
							dlog.log(_err,filepath);	
							dlog.cronErrEmail("Material cogs overseas email not sent",_err);	
						}else{
							functions.cogsOverseasEmail(_res,yesterday).then(
							(emailtemp) => {
								routes.materialCogsOverseasEmailList(emailtemp, (_err1, emailres) => {									
									if(_err1){
										console.log(_err1);
										dlog.log(_err1,filepath);
										dlog.cronErrEmail("Material cogs overseas email not sent",_err1);	
									}else{
										dlog.cronEmail(emailtemp,emailres,yesterday,5,(_err2, _res2) => {											
											if(_err2){
												    console.log(_err2);
										            dlog.log(_err2,filepath);
													dlog.cronErrEmail("Material cogs overseas email not sent","error in cronEmail");	
											}else{
												 console.log(_res2);	
											}
										})
										
									}
									
								})
								 
							})
							
						}
    });
	
})



exports.schedule = cron.schedule('00 03 * * *', () => {
//exports.schedule = cron.schedule('37 13 * * *', () => {
		
	var today = new Date();
	var yesterday = new Date(today);
	yesterday.setDate(today.getDate() - 1);
	var dd = yesterday.getDate();
	var mm = yesterday.getMonth()+1; //January is 0!
	var yyyy = yesterday.getFullYear();
	if(dd<10){dd='0'+dd} if(mm<10){mm='0'+mm} 
	yesterday = yyyy+'-'+mm+'-'+dd;
	
	var currentmonth = today.getMonth()+1;
	var fromdate = yyyy+'-'+mm+'-01';
	var todate = yesterday;
	routes.deleteStockLedger(currentmonth,mm,yesterday, (_err, _res) => {
								if(_err){
									console.log(_err);
									console.log("Delete query error : stock_ledger");
								}else{
									console.log(_res);
									console.log("Start insert")	
									connections.ideamed.getConnection((err, con) => {
									if (err) {
										console.log('Connection Error : ideamed');
									}else{
										con.query(files.stock_ledger_domestic_IM, (ideaerr, ideares) => {
											if (ideaerr){ 
												console.log('Stock ledger query Error : ideamed');
											}else{
												console.log('Connected to Ideamed.')
												console.log('Inserting Records for stock_ledger table.Please Wait...')
												con.beginTransaction(err => {
													if (err) {
														console.log(err);
													}else{
														ideares.forEach(record => {
															//console.log(record);
															connections.scm_root.query('insert into stock_ledger set ?', record, (error) => {
																if (error) {								
																	console.log(error);
																	return con.rollback(function () {
																		console.error(error)
																	});
																}
																con.commit(function (err) {
																	if (err) {
																		console.log(err);
																		return con.rollback(function () {
																			console.error(err)
																		});
																	}
																});
															})
														})
														console.log("Finished insert  stock_ledger.")
													}
												})
											
											}
										})
										
									}
									con.release();
									})
									
									
								} 
				})
    
	console.log('completed');
})



exports.schedule = cron.schedule('00 04 * * *', () => {
//exports.schedule = cron.schedule('53 13 * * *', () => {		
	var today = new Date();
	var yesterday = new Date(today);
	yesterday.setDate(today.getDate() - 1);
	var dd = yesterday.getDate();
	var mm = yesterday.getMonth()+1; //January is 0!
	var yyyy = yesterday.getFullYear();
	if(dd<10){dd='0'+dd} if(mm<10){mm='0'+mm} 
	yesterday = yyyy+'-'+mm+'-'+dd;
	
	var currentmonth = today.getMonth()+1;
	var fromdate = yyyy+'-'+mm+'-01';
	var todate = yesterday;
	routes.deleteStockLedgerOverseas(currentmonth,mm,yesterday, (_err, _res) => {
								if(_err){
									console.log(_err);
									console.log("Delete query error overseas : stock_ledger");
								}else{
									console.log(_res);
									console.log("Start insert")	
									connections.ideamed.getConnection((err, con) => {
									if (err) {
										console.log('Connection Error : ideamed');
									}else{
										con.query(files.stock_ledger_overseas_IM, (ideaerr, ideares) => {
											if (ideaerr){ 
												console.log('Stock ledger query Error : ideamed');
											}else{
												console.log('Connected to Ideamed.')
												console.log('Inserting Records for stock_ledger table.Please Wait...')
												con.beginTransaction(err => {
													if (err) {
														console.log(err);
													}else{
														ideares.forEach(record => {
															//console.log(record);
															connections.scm_root.query('insert into stock_ledger set ?', record, (error) => {
																if (error) {								
																	console.log(error);
																	return con.rollback(function () {
																		console.error(error)
																	});
																}
																con.commit(function (err) {
																	if (err) {
																		console.log(err);
																		return con.rollback(function () {
																			console.error(err)
																		});
																	}
																});
															})
														})
														console.log("Finished insert overseas stock_ledger.")
													}
												})
											
											}
										})
										
									}
									con.release();
									})
									
									
								} 
				})
    
	console.log('completed');
})




//stns

exports.schedule = cron.schedule('00 23 * * *', () => {

  var today = new Date();
  var dd = String(today.getDate()).padStart(2, '0');
  var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
  var yyyy = today.getFullYear();

  today = yyyy + '/' + mm + '/' + dd;



  connections.scm_public.query("SELECT * FROM email WHERE scmtype='stn'", function(err, result, fields) {
    if (err) throw err;

    console.log("email fetched");

    connections.ideamed.query(files.stns, function(err, result1, fields) {

      var frmid = '';
      var toid = '';
      var bccid = '';
      var ccid = '';
      var passcode = '';
      for (var j = 0; j < result.length; j++) {
        frmid = result[j].fromid
        toid = result[j].toid
        bccid = result[j].bccid
        ccid = result[j].ccid
        passcode = result[j].passcode

      }

      var nodemailer = require('nodemailer');
      console.log(frmid);
      console.log(passcode);

      var transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
          user: frmid,
          pass: passcode
        }
      });

      var table = '';
      console.log(result1.length);

      if (result.length > 0) {
        for (i = 0; i < result1.length; i++) {
          table += '<tr><td>' + result1[i].ISSUE_ID + '</td><td>' + result1[i].STNRETURN + '</td><td>' + result1[i].ISSUEDDATE + '</td><td>' + result1[i].ITEM_NAME + '</td><td>' + result1[i].BATCH_NO + '</td><td>' + result1[i].EXPIRYDATE + '</td><td>' + result1[i].ISSUED_QUANTITY + '</td><td>' + result1[i].MRP + '</td><td>' + result1[i].COSTPRICE + '</td><td>' + result1[i].UNITPRICE + '</td><td>' + result1[i].ISSUING_DEPARTMENT + '</td><td>' + result1[i].RECEIVING_DEPARTMENT + '</td><td>' + result1[i].USER_NAME + '</td><td>' + result1[i].HSN_SAC + '</td></tr>';
        }
        table = '<html><body><table border="1" cellspacing="0"><tr><th colspan="17">Stock Transfer on ' + today + ' </th></tr><tr><th>ISSUE_ID</th><th>STNRETURN</th><th>ISSUEDDATE</th><th>ITEM_NAME</th><th>BATCH_NO</th><th>EXPIRYDATE</th><th>ISSUED_QUANTITY</th><th>MRP</th><th>COSTPRICE</th><th>UNITPRICE</th><th>ISSUING_DEPARTMENT</th><th>RECEIVING_DEPARTMENT</th><th>USER_NAME</th><th>HSN_SAC</th></tr>' + table + '</table> <br><b>Note: This report is auto generated, please do not reply.</b> <br><p>For any corrections, please drop a mail to  <a href="mailto:ramu.ravi@dragarwal.com">ramu.ravi@dragarwal.com</a>. </p> <br><p>Regards,</p><p>Dr.Agarwal IT Team</p></body></html>'

      } else {
        table = "No data Available";
      }

      let mailOptions = {
        from: frmid,
        to: toid,
        bcc: bccid,
        cc: ccid,
        subject: 'GST: Daily report of Ideamed Stock Transfer on ' + today,
        html: table
      };

      transporter.sendMail(mailOptions, function(error, info) {
        if (error) {
          console.log(error);
        } else {
          console.log('Email sent: ' + info.response);
        }
      });


    })


  })

})

exports.schedule = cron.schedule('45 06 * * *', () => {
//exports.schedule = cron.schedule('28 13 * * *', () => {
  connections.ideamed.getConnection((err, con) => {
    if (err) console.log("connections err");
    //  let queryres = "SELECT  BPB.ID as 'bill_id',BPB.BILL_NO as 'bill_no',BPB.TPA_CLAIM_ID as 'tpa_claim' FROM BILL_PATIENT_BILL AS BPB WHERE DATE(REVENUE_DATE)=DATE_SUB(CURDATE(), INTERVAL 1 DAY) AND CLAIM_AMOUNT >0";

    con.query(files.revenuedetailstpa, (err, res) => {
      if (err) console.error(err);
      console.log("connected to ideamed");
      console.log("inserting record for tpa bill.. please wait");
      con.beginTransaction(err => {
        if (err) console.error(err);
        res.forEach(record => {
          connections.scm_root.query("insert into revenue_detail_tpa set ?", record, (error) => {
            if (error) {
              return con.rollback(function() {
                console.error(error);
              })
            } else {

              con.commit(function(err) {
                if (error) {
                  return con.rollback(function() {
                    console.error(error);
                  })
                }

              })
            }


          });
        });
		console.log("Completed");
      });
    });

    con.release();
  })


})


exports.schedule = cron.schedule('10 07 * * *', () => {
//exports.schedule = cron.schedule('37 13 * * *', () => {
	console.log("start");
	var today = new Date();	
	var dd = today.getDate();
	var mm = today.getMonth()+1; //January is 0!
	var yyyy = today.getFullYear();
	if(dd<10){dd='0'+dd} if(mm<10){mm='0'+mm} 
	fromdate = yyyy+'-'+mm+'-'+01;
	todate = yyyy+'-'+mm+'-'+31;

    var month = today.getMonth()+1;	
	
	//fromdate = yyyy+'-04'+'-'+01;
	//todate = yyyy+'-04'+'-'+31;	
	
	 if(dd>=02){
		 return new Promise((resolve, reject) => {
				async.parallel({
					paid_op: (callback) => {

						routes.paid_opQuery(fromdate, todate, (_err, _res) => {
							callback(_err, _res);
						});

					},
					total_consu: (callback) => {

						routes.total_consuQuery(fromdate, todate, (_err, _res) => {
							callback(_err, _res);
						});

					},
					all_cat_surg: (callback) => {

						routes.all_cat_surgQuery(fromdate, todate, (_err, _res) => {
							callback(_err, _res);
						});

					},
					cat_low_end: (callback) => {

						routes.cat_low_endQuery(fromdate, todate, (_err, _res) => {
							callback(_err, _res);
						});

					},
					cat_mid_end: (callback) => {

						routes.cat_mid_endQuery(fromdate, todate, (_err, _res) => {
							callback(_err, _res);
						});

					},
					cat_high_end: (callback) => {

						routes.cat_high_endQuery(fromdate, todate, (_err, _res) => {
							callback(_err, _res);
						});

					},
					corena: (callback) => {

						routes.corenaQuery(fromdate, todate, (_err, _res) => {
							callback(_err, _res);
						});

					},
					referctive: (callback) => {

						routes.referctiveQuery(fromdate, todate, (_err, _res) => {
							callback(_err, _res);
						});

					},
					vr_inj: (callback) => {

						routes.vrInjQuery(fromdate, todate, (_err, _res) => {
							callback(_err, _res);
						});

					},
					vr_surg: (callback) => {

						routes.vrSurgQuery(fromdate, todate, (_err, _res) => {
							callback(_err, _res);
						});

					},
					phar: (callback) => {

						routes.pharQuery(fromdate, todate, (_err, _res) => {
							callback(_err, _res);
						});

					},
					optical: (callback) => {

						routes.opticalQuery(fromdate, todate, (_err, _res) => {
							callback(_err, _res);
						});

					},
					contactlens: (callback) => {

						routes.contactQuery(fromdate, todate, (_err, _res) => {
							callback(_err, _res);
						});

					},
					other_sug: (callback) => {

						routes.otherSugQuery(fromdate, todate, (_err, _res) => {
							callback(_err, _res);
						});

					},
					treat: (callback) => {

						routes.treatQuery(fromdate, todate, (_err, _res) => {
							callback(_err, _res);
						});

					},
					invest: (callback) => {

						routes.investQuery(fromdate, todate, (_err, _res) => {
							callback(_err, _res);
						});

					},
					branches: (callback) => {

						routes.branchesDetailsOPR('', '', (_err, _res) => {
							callback(_err, _res);
						});

					}
					
				}, (err, results) => {
					if (err) {
					   console.log(err);
					   
					} else {
						
						//console.log(results);
								functions.insertOPRData(
								results.paid_op,
								results.total_consu,
								results.all_cat_surg,
								results.cat_low_end,
								results.cat_mid_end,
								results.cat_high_end,
								results.corena,
								results.referctive,
								results.vr_inj,
								results.vr_surg,
								results.phar,
								results.optical,
								results.contactlens,
								results.other_sug,
								results.treat,
								results.invest,
								results.branches,
								yyyy,
								month
								).then(
								(oprDataResult) => {
									
									routes.insertOPRDataTable(oprDataResult,yyyy,mm, (_err, _res) => {
										if(_err){
											console.log(_err);
											dlog.cronErrEmail("OPR data insert error",_err);
										}else{
											console.log(_res);
											dlog.cronErrEmail("OPR data insert success","success");
										}
										
										
									});
									
									 
								})
						
									
						
					}
					
				});

		});
	}else{
		console.log("not inserted")
	}
})


//praveen 15days intransit Report

exports.schedule=cron.schedule('10 11 * * *',() =>{


 var date = new Date();
 var lstDay =new Date(date.getFullYear(), date.getMonth() + 1, 0);
 var lastday=lstDay.getDate();

 var dat = date.getDate();
 var mon = date.getMonth() + 1;
 var yr = date.getFullYear();
  var today = yr + '-' + mon + '-' + dat;

   if( dat==15 || dat==lastday)
   {
		var filepath = '/home/ubuntu/scmlogs/intransit_cron_' + '_' + today + '.txt';

		  routes.main_routes_intransit(dat,(err,emailtemp)=>{

			if(err){
			  //console.log(_err1);
			  dlog.log(_err1, filepath);
			  dlog.cronErrEmail("Intransit email not sent", _err1);
			}
			else {

			routes.intransitEmailList(emailtemp,(err1,emailres)=>{
			  if(err1){
				//console.log(_err1);
				dlog.log(_err1, filepath);
				dlog.cronErrEmail("Intransit email not sent", _err1);
			  }
			  else {
				dlog.cronEmail(emailtemp,emailres,today,8,(err2,res2)=>{
				  if(err2){
					//console.log(_err2);
					dlog.log(_err2, filepath);
					dlog.cronErrEmail("Intransit email not sent", "error in cronEmail");

				  }
				  else {
					//console.log(res2);
				  }
				})
			  }
			})
			}

		  })
  
   }



})
/*

//collection_recon -2
exports.schedule = cron.schedule("30 01 * * *",()=>{
//exports.schedule = cron.schedule("58 11 * * *",()=>{
console.log("hit in cron ");

connections.scm_root.getConnection((err,con)=>{
  console.log("connection established");
    if(err) console.error("error");

    con.query(files.collection_recon_update,(err,collresdata)=>{
      console.log("query executed");
      if(err) console.error(err);
      console.log("connected to medics");
      console.log("updating in collection recon");
      con.beginTransaction(err=>{
        if(err) console.error(err);
		
		//console.log(collresdata);

        collresdata.forEach(records=>{
			
			
			
			//console.log(records);
          // Current date update
       con.query("update collection_recon set CASH_AMOUNT=?,CARD_AMOUNT=?,CHEQUE_AMOUNT=?,FUND_TRANSFER_AMOUNT=?,PAYTM_AMOUNT=?,DD_AMOUNT=?,ONLINE_AMOUNT=? WHERE PAYMENT_OR_REFUND_DATE=? AND BRANCH=?",[records.CASH_AMOUNT,records.CARD_AMOUNT,records.CHEQUE_AMOUNT,records.FUND_TRANSFER_AMOUNT,records.PAYTM_AMOUNT,records.DD_AMOUNT,records.ONLINE_AMOUNT,records.PAYMENT_OR_REFUND_DATE,records.BRANCH],(err,resdata)=>{
		
		
		
		 /*console.log("insert into  collection_recon set CASH_AMOUNT='"+records.CASH_AMOUNT+"',CARD_AMOUNT='"+records.CARD_AMOUNT+"',CHEQUE_AMOUNT='"+records.CHEQUE_AMOUNT+"',FUND_TRANSFER_AMOUNT='"+records.FUND_TRANSFER_AMOUNT+"',PAYTM_AMOUNT='"+records.PAYTM_AMOUNT+"',DD_AMOUNT='"+records.DD_AMOUNT+"',ONLINE_AMOUNT='"+records.ONLINE_AMOUNT+"',BRANCH='"+records.BRANCH+"'");
		con.query("insert into  collection_recon set CASH_AMOUNT='"+records.CASH_AMOUNT+"',CARD_AMOUNT='"+records.CARD_AMOUNT+"',CHEQUE_AMOUNT='"+records.CHEQUE_AMOUNT+"',FUND_TRANSFER_AMOUNT='"+records.FUND_TRANSFER_AMOUNT+"',PAYTM_AMOUNT='"+records.PAYTM_AMOUNT+"',DD_AMOUNT='"+records.DD_AMOUNT+"',ONLINE_AMOUNT='"+records.ONLINE_AMOUNT+"',BRANCH='"+records.BRANCH+"'",(err,resdata)=>{*/
		/*
		
            if (err) {
              return con.rollback(function() {
                console.error(error)
              });
            }
            else {
				
				//console.log("********");
              // update next date in recon
              con.query("UPDATE collection_recon SET CASH_DIFF=(SELECT * FROM (SELECT SUM(A.CASH_DEPOSIT)+SUM(A.CASH_ADMIN)-SUM(A.CASH_AMOUNT) AS CST FROM collection_recon AS A WHERE A.BRANCH=? )AS B),CARD_DIFF= (SELECT * FROM (SELECT SUM(A.CARD_DEPOSIT)+SUM(A.CARD_ADMIN)-SUM(A.CARD_AMOUNT) AS CRT FROM collection_recon AS A WHERE A.BRANCH=?)AS B) WHERE PARENT_BRANCH IN ('AEH','AHC','AHI') AND PAYMENT_OR_REFUND_DATE between curdate() and DATE_ADD(curdate(),INTERVAL 1 DAY) AND BRANCH=?",[records.BRANCH,records.BRANCH,records.BRANCH],(err,resdatas=>{
                if(err){
                  console.error(err);
                }
                else{

                  con.commit(function(err) {
                     if (err) {
                       return con.rollback(function() {
                         console.error(err);
                       });
                     }
                   })


                  

                  console.log("updated");
                }

              })
            )

            }

          })


        })


      })
    con.release();
    })

})

})

*/


//collection_recon -2
exports.schedule = cron.schedule("30 01 * * *",()=>{
//exports.schedule = cron.schedule("13 14 * * *",()=>{
console.log("hit in cron ");

connections.scm_root.getConnection((err,con)=>{
  console.log("connection established");
    if(err) console.error("error");
	
	//files.collection_recon_update

    con.query("select CODE from branches where entity IN ('AEH','AHC','AHI')",(err,branchres)=>{
      console.log("query executed");
      if(err) console.error(err);
      console.log("connected to medics");
      console.log("updating in collection recon");
      con.beginTransaction(err=>{
        if(err) console.error(err);
		
		//console.log(collresdata);

        branchres.forEach(branres=>{
			
			con.query("SELECT PARENT_BRANCH,BRANCH,PAYMENT_OR_REFUND_DATE,SUM(CASH_AMOUNT)+SUM(REFUND_CASH_AMOUNT)  AS CASH_AMOUNT,SUM(CARD_AMOUNT)+SUM(CARD_SERVICE_CHARGE_AMOUNT)+SUM(REFUND_CARD_AMOUNT) AS CARD_AMOUNT,SUM(CHEQUE_AMOUNT)+SUM(REFUND_CHEQUE_AMOUNT) AS CHEQUE_AMOUNT,SUM(FUND_TRANSFER_AMOUNT) AS FUND_TRANSFER_AMOUNT,SUM(PAYTM_AMOUNT) AS PAYTM_AMOUNT,SUM(DD_AMOUNT) AS DD_AMOUNT,SUM(ONLINE_AMOUNT) AS ONLINE_AMOUNT FROM collection_detail  WHERE PAYMENT_OR_REFUND_DATE = curdate() and branch='"+branres.CODE+"'",(err,records)=>{
				
				//console.log(records);
				// Current date update
				con.query("update collection_recon set CASH_AMOUNT=?,CARD_AMOUNT=?,CHEQUE_AMOUNT=?,FUND_TRANSFER_AMOUNT=?,PAYTM_AMOUNT=?,DD_AMOUNT=?,ONLINE_AMOUNT=? WHERE PAYMENT_OR_REFUND_DATE=? AND BRANCH=?",[records[0].CASH_AMOUNT,records[0].CARD_AMOUNT,records[0].CHEQUE_AMOUNT,records[0].FUND_TRANSFER_AMOUNT,records[0].PAYTM_AMOUNT,records[0].DD_AMOUNT,records[0].ONLINE_AMOUNT,records[0].PAYMENT_OR_REFUND_DATE,records[0].BRANCH],(err,resdata)=>{
				/*console.log("insert into  collection_recon set CASH_AMOUNT='"+records.CASH_AMOUNT+"',CARD_AMOUNT='"+records.CARD_AMOUNT+"',CHEQUE_AMOUNT='"+records.CHEQUE_AMOUNT+"',FUND_TRANSFER_AMOUNT='"+records.FUND_TRANSFER_AMOUNT+"',PAYTM_AMOUNT='"+records.PAYTM_AMOUNT+"',DD_AMOUNT='"+records.DD_AMOUNT+"',ONLINE_AMOUNT='"+records.ONLINE_AMOUNT+"',BRANCH='"+records.BRANCH+"'");
				con.query("insert into  collection_recon set CASH_AMOUNT='"+records.CASH_AMOUNT+"',CARD_AMOUNT='"+records.CARD_AMOUNT+"',CHEQUE_AMOUNT='"+records.CHEQUE_AMOUNT+"',FUND_TRANSFER_AMOUNT='"+records.FUND_TRANSFER_AMOUNT+"',PAYTM_AMOUNT='"+records.PAYTM_AMOUNT+"',DD_AMOUNT='"+records.DD_AMOUNT+"',ONLINE_AMOUNT='"+records.ONLINE_AMOUNT+"',BRANCH='"+records.BRANCH+"'",(err,resdata)=>{*/


				if (err) {					
					//console.log(err);					
					return con.rollback(function() {
					console.error(error)
					});
				}
				else {

					//console.log("********");
					
					// update next date in recon
					con.query("UPDATE collection_recon SET CASH_DIFF=(SELECT * FROM (SELECT SUM(A.CASH_DEPOSIT)+SUM(A.CASH_ADMIN)-SUM(A.CASH_AMOUNT) AS CST FROM collection_recon AS A WHERE A.BRANCH=? )AS B),CARD_DIFF= (SELECT * FROM (SELECT SUM(A.CARD_DEPOSIT)+SUM(A.CARD_ADMIN)-SUM(A.CARD_AMOUNT) AS CRT FROM collection_recon AS A WHERE A.BRANCH=?)AS B) WHERE PARENT_BRANCH IN ('AEH','AHC','AHI') AND PAYMENT_OR_REFUND_DATE between curdate() and DATE_ADD(curdate(),INTERVAL 1 DAY) AND BRANCH=?",[branres.CODE,branres.CODE,branres.CODE],(err,resdatas=>{
					if(err){
						console.log(err);
						//process.exit(1);
					}
					else{

						con.commit(function(err) {
						if (err) {
						return con.rollback(function() {
						console.error(err);
						});
						}
						})
						console.log("updated");
					}

					})
					)

				}

				})
				
				
				
			});
			
			

		//for loop end
        })


      })
    con.release();
    })

})

})



exports.schedule = cron.schedule('00 21 * * *', () => {
//exports.schedule = cron.schedule('53 11 * * *', () => {	
    
	var today = new Date();
	
	var dd = today.getDate();
	var mm = today.getMonth()+1; //January is 0!
	var yyyy = today.getFullYear();
	if(dd<10){dd='0'+dd} if(mm<10){mm='0'+mm} 
	today = yyyy+'-'+mm+'-'+dd;
	
	//today = '2021-06-21';
    //var filepath = '/home/ubuntu/scmlogs/materialcogs_overseas_email_cron_'+'_'+yesterday+'.txt';   
	var filepath = '/home/ubuntu/scmlogs/cash_recon_finance_email_cron_'+'_'+today+'.txt';   
   
							
							
	routes.collreconFin(today, (_err, _res) => {
			if(_err){
				
				dlog.log(_err,filepath);	
				dlog.cronErrEmail("Cash Recon Fin email not sent",_err);	
			}else{
				functions.collreconFinEmailTemp(_res,today).then(
				(emailtemp) => {
					routes.financeemaillist(emailtemp, (_err1, emailres) => {									
						if(_err1){
							
							dlog.log(_err1,filepath);
							dlog.cronErrEmail("Cash Recon Fin email not sent",_err1);	
						}else{
							dlog.cronEmail(emailtemp,emailres,today,9,(_err2, _res2) => {											
								if(_err2){
										
										dlog.log(_err2,filepath);
										dlog.cronErrEmail("Cash Recon Fin email not sent","error in cronEmail");	
								}else{
									 console.log(_res2);	
								}
							})
							
						}
						
					})
					 
				})
				
			}
    });
							
						
	
})







/*exports.schedule = cron.schedule('15 21 * * *', () => {
//exports.schedule = cron.schedule('54 13 * * *', () => {	
    
	var today = new Date();
	
	var dd = today.getDate();
	var mm = today.getMonth()+1; //January is 0!
	var yyyy = today.getFullYear();
	if(dd<10){dd='0'+dd} if(mm<10){mm='0'+mm} 
	today = yyyy+'-'+mm+'-'+dd;
	
	//today = '2021-06-21';
    //var filepath = '/home/ubuntu/scmlogs/materialcogs_overseas_email_cron_'+'_'+yesterday+'.txt';   
	var filepath = '/home/ubuntu/scmlogs/cash_recon_ch_email_cron_'+'_'+today+'.txt';
	routes.collreconCH(today, (_err, _res) => {
			if(_err){
				
				dlog.log(_err,filepath);	
				dlog.cronErrEmail("Cash Recon CH email not sent",_err);	
			}else{
				if(_res.length>0){					
					for(var i=0; i<_res.length; i++){            
						 
						  functions.collreconCHTemplate(_res[i], (_err, tempres) => {
							if(_err){
								dlog.log(_err,filepath);	
								dlog.cronErrEmail("Cash Recon CH email not sent",_err);
							}else{
									routes.collreconCHList(_res[i].BRANCH, (_err, emailres) => {
									if(_err){
										dlog.log(_err,filepath);	
										dlog.cronErrEmail("Cash Recon CH email not sent",_err);
									}else{
										if(emailres[0].ch_email!=null){
											routes.financeemaillistCH(tempres, (_err1, fiCHEmailres) => {
												if(_err1){
													dlog.log(_err1,filepath);	
										           dlog.cronErrEmail("Cash Recon CH email not sent",_err1);
												}
												else{
													dlog.cashReconCHEmail(tempres,emailres,fiCHEmailres,today,8,(_err2, _res2) => {										
													if(_err2){															
															dlog.log(_err2,filepath);
															
													}else{
														 console.log(_res2);
																													 
													}
													})
												}
											})
										}
										
									}
								})
								
							}
						})
					}
					
				}else{
					
				}
			}
    });
							
						
	
})
*/



exports.schedule = cron.schedule('30 21 * * 4', () => {
//exports.schedule = cron.schedule('37 18 * * *', () => {	
    
	var today = new Date();
	
	var dd = today.getDate();
	var mm = today.getMonth()+1; //January is 0!
	var yyyy = today.getFullYear();
	if(dd<10){dd='0'+dd} if(mm<10){mm='0'+mm} 
	var hh=today.getHours();
	var mi=today.getMinutes();
	var ss=today.getSeconds();
	
	today = yyyy+'-'+mm+'-'+dd;
	
	var todaytime = yyyy+'-'+mm+'-'+dd+' '+hh+':'+mi+':'+ss;
	
	//today = '2021-06-21';
    //var filepath = 'D:/git/live-cogs-api-final/cash_recon_finance_email_cron_weekly'+'_'+today+'.txt';   
	var filepath = '/home/ubuntu/scmlogs/cash_recon_finance_email_cron_weekly'+'_'+today+'.txt'; 
	
    connections.scm_root.query('update editable_dates set collection_deposit_edit="'+todaytime+'" where id=1', (error,res) => {
		if (error) {
			
		}else{			
			routes.collreconWeekly(today, (_err, _res) => {
			if(_err){
				
				dlog.log(_err,filepath);	
				dlog.cronErrEmail("Cash Recon Fin week email not sent",_err);	
			}else{
				functions.collreconFinEmailTempWeekly(_res,today).then(
				(emailtemp) => {
					routes.financeemaillistweekly(emailtemp, (_err1, emailres) => {									
						if(_err1){
							
							dlog.log(_err1,filepath);
							dlog.cronErrEmail("Cash Recon Fin week email not sent",_err1);	
						}else{
							dlog.cronEmail(emailtemp,emailres,today,10,(_err2, _res2) => {											
								if(_err2){
										
										dlog.log(_err2,filepath);
										dlog.cronErrEmail("Cash Recon Fin week email not sent","error in cronEmail");	
								}else{
									 console.log(_res2);	
								}
							})
							
						}
						
					})
					 
				})
				
			}
			});
			
		}
	})				
	
})




exports.schedule = cron.schedule('30 08 * * *', () => {
//exports.schedule = cron.schedule('58 10 * * *', () => {
    connections.ideamed.getConnection((err, con) => {
        if (err) console.log('Connection Error.')
        con.query(files.paid_op_details, (ideaerr_op, ideares_op) => {
            if (ideaerr_op) console.error(ideaerr_op)
            console.log('Connected to Ideamed.')
            console.log('Inserting Records for paid_op_details.Please Wait...')
            con.beginTransaction(err => {
                if (err) console.error(err)
                ideares_op.forEach(record => {
					
					//console.log(record);
                    connections.scm_root.query('insert into paid_op_details set ?', record, (error) => {
                        if (error) {
                            return con.rollback(function () {
                                console.error(error)
                            });
                        }
                        con.commit(function (err) {
                            if (err) {
                                return con.rollback(function () {
                                    console.error(err)
                                });
                            }
                        });
                    })
                })
               
            })
        })
    })
    console.log('completed');
})


// Netsuite Collection Interface
exports.schedule = cron.schedule('45 01 * * *', () => {
	//exports.schedule = cron.schedule('58 10 * * *', () => {
		connections.scm_root.getConnection((err, con) => {
			if (err) console.log('Connection Error.')
			con.query(files.Ns_collection_upload, (ideaerr_op, ideares_op) => {
				if (ideaerr_op) console.error(ideaerr_op)
				console.log('Connected to SCM.')
				console.log('Inserting Records for Collection Upload.Please Wait...')
				con.beginTransaction(err => {
					if (err) console.error(err)
					ideares_op.forEach(record => {
						
						//console.log(record);
						connections.scm_root.query('insert into COLLECTION_UPLOAD set ?', record, (error) => {
							if (error) {
								return con.rollback(function () {
									console.error(error)
								});
							}
							
							con.commit(function (err) {
								if (err) {
									return con.rollback(function () {
										console.error(err)
									});
								}
							});
						})

						connections.scm_root.query('UPDATE COLLECTION_UPLOAD SET `DATE` =LEFT(EXTERNAL_ID,10) WHERE `DATE` = "0000-00-00"', (error,res) => {
							if (error) {
								return con.rollback(function () {
									console.error(error)
								});
							}
							 
							con.commit(function (err) {
								if (err) {
									return con.rollback(function () {
										console.error(err)
									});
								}
							});
						})
						 
					})
				   
				})
			})
		})
		console.log('completed');
	})


	exports.schedule = cron.schedule('00 02 * * *', () => {
		//exports.schedule = cron.schedule('37 13 * * *', () => {
				
			var today = new Date();
			var yesterday = new Date(today);
			yesterday.setDate(today.getDate() - 1);
			var dd = yesterday.getDate();
			var mm = yesterday.getMonth()+1; //January is 0!
			var yyyy = yesterday.getFullYear();
			if(dd<10){dd='0'+dd} if(mm<10){mm='0'+mm} 
			yesterday = yyyy+'-'+mm+'-'+dd;
			
			var currentmonth = today.getMonth()+1;
			var fromdate = yyyy+'-'+mm+'-01';
			var todate = yesterday;
			routes.deletebatchwisestock(currentmonth,mm,yesterday, (_err, _res) => {
										if(_err){
											console.log(_err);
											console.log("Delete batch query error : stock_ledger");
										}else{
											console.log(_res);
											console.log("Start batch insert")	
											connections.ideamed.getConnection((err, con) => {
											if (err) {
												console.log('Connection Error : ideamed');
											}else{
												con.query(files.Batch_Wise_stock, (ideaerr, ideares) => {
													if (ideaerr){ 
														console.log('Batch Stock ledger query Error : ideamed');
													}else{
														console.log('Connected to Ideamed.')
														console.log('Inserting Records for batchwise table.Please Wait...')
														con.beginTransaction(err => {
															if (err) {
																console.log(err);
															}else{
																ideares.forEach(record => {
																	//console.log(record);
																	connections.scm_root.query('insert into BATCH_WISE_STOCK set ?', record, (error) => {
																		if (error) {								
																			console.log(error);
																			return con.rollback(function () {
																				console.error(error)
																			});
																		}
																		con.commit(function (err) {
																			if (err) {
																				console.log(err);
																				return con.rollback(function () {
																					console.error(err)
																				});
																			}
																		});
																	})
																})
																console.log("Finished insert batch stock_ledger.")
															}
														})
													
													}
												})
												
											}
											con.release();
											})
											
											
										} 
						})
			
			console.log('completed');
		})
		