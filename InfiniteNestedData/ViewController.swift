//
//  ViewController.swift
//  InfiniteNestedData
//
//  Created by Richard S on 23/03/2015.
//  Copyright (c) 2015 Richard S. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	var faqData:Array<AnyObject>?
	@IBOutlet var tableView:UITableView!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		if (self.faqData == nil) {
			self.fetchFAQ { (data) -> Void in
				self.faqData = data
				self.tableView.reloadData()
			}
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "showNextPage") {
			let destVC:ViewController = segue.destinationViewController as! ViewController
			let selectedRow = self.tableView.indexPathForSelectedRow()!.row
			let content:Array<AnyObject> = self.faqData![selectedRow]["children"] as! Array<AnyObject>
			destVC.faqData = content
		}
	}

	func fetchFAQ(completion:(Array<AnyObject>?) -> Void) {
		
		let url = NSURL(string: "http://localhost:9999/data.json")!
		let dataTask = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
			if let json:AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) {
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					completion(json as? Array<AnyObject>)
				})
			}
		})
		dataTask.resume()
		
	}
	
	// MARK: Tableview Delegate
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (self.faqData != nil) {
			return count(self.faqData!)
		}
		return 0
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		self.performSegueWithIdentifier("showNextPage", sender: self)
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell:InfoTableViewCell = tableView.dequeueReusableCellWithIdentifier("infoCell") as! InfoTableViewCell
		if let infoDict:Dictionary<String, AnyObject> = self.faqData![indexPath.row] as? Dictionary<String, AnyObject> {

			cell.infoLabel.text = infoDict["title"] as? String
			cell.userInteractionEnabled = false
			if let children:Array<AnyObject> = infoDict["children"] as? Array<AnyObject> {
				if (count(children) > 0) {
					cell.userInteractionEnabled = true
				}
			}
		}
		
		return cell
	}

}

