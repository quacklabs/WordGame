//
//  ViewController.swift
//  WordGame
//
//  Created by Sprinthub on 12/02/2019.
//  Copyright © 2019 Sprinthub Mobile. All rights reserved.

//mind the 

import UIKit

class ViewController: UIViewController {
    
    
    //MARK: Button Definitions
    
    //conncection for our clues label
    @IBOutlet var cluesLabel: UILabel!
    
    //connection for our answer label field
    @IBOutlet var answersLabel: UILabel!
    
    //connection for our current answer text field
    @IBOutlet var currentAnswer: UITextField!
    
    //connection for our scores label
    @IBOutlet var scoresLabel: UILabel!
    
    
    
    //action for our submit button
    @IBAction func submitTapped(_ sender: UIButton) {
        if let solutionPosition = solutions.index(of: currentAnswer.text!) {
            activatedButtons.removeAll()
            
            var splitAnswers = answersLabel.text!.components(separatedBy: "\n")
            splitAnswers[solutionPosition] = currentAnswer.text!
            answersLabel.text = splitAnswers.joined(separator: "\n")
            
            currentAnswer.text = ""
            score += 1
            
            if score % 7 == 0 {
                let ac = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: levelUp))
                present(ac, animated: true)
            }
        }
    }
    
    
    //MARK: Button actions
    
    
    //action for our clear button
    @IBAction func clearTapped(_ sender: UIButton) {
        currentAnswer.text = ""
        
        for btn in activatedButtons {
            btn.isHidden = false
        }
        
        activatedButtons.removeAll()
    }
    
    var letterButtons = [UIButton]()
    var activatedButtons = [UIButton]()
    var solutions = [String]()
    
    var score = 0 {
        
        //using a property observer, we update the score on the UI whenever the property is updated. Cool huh?
        didSet {
            scoresLabel.text = "Score: \(score)"
        }
    }
    var level = 1
    var levelCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //map all letter buttons to one function
        for subview in view.subviews where subview.tag == 1001 {
            let btn = subview as! UIButton
            letterButtons.append(btn)
            btn.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
        }
        
        loadLevel()
    }
    
    //capture letter tapped action
    @objc func letterTapped(btn: UIButton) {
        currentAnswer.text = currentAnswer.text! + btn.titleLabel!.text!
        activatedButtons.append(btn)
        btn.isHidden = true
    }
    
    
    //MARK: Game Logic
    
    //Load a level
    func loadLevel() {
        var clueString = ""
        var solutionString = ""
        var letterBits = [String]()
        
        if let levelFilePath = Bundle.main.path(forResource: "level\(level)", ofType: "txt") {
            //set our level count
            levelCount = levelFilePath.count
            //get level words from file
            if let levelContents = try? String(contentsOfFile: levelFilePath) {
                var lines = levelContents.components(separatedBy: "\n")
                lines.shuffle()
                
                for (index, line) in lines.enumerated() {
                    let parts = line.components(separatedBy: ": ")
                    let answer = parts[0]
                    let clue = parts[1]
                    
                    clueString += "\(index + 1). \(clue)\n"
                    
                    let solutionWord = answer.replacingOccurrences(of: "|", with: "")
                    solutionString += "\(solutionWord.count) letters\n"
                    solutions.append(solutionWord)
                    
                    let bits = answer.components(separatedBy: "|")
                    letterBits += bits
                }
            }
        }
        
        // Now configure the buttons and labels
        cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
        answersLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        letterBits.shuffle()
        
        if letterBits.count == letterButtons.count {
            for i in 0 ..< letterButtons.count {
                letterButtons[i].setTitle(letterBits[i], for: .normal)
            }
        }
    }
    
    
    //Load next level
    func levelUp(action: UIAlertAction) {
//        if level >= levelCount {
//            UIAlertAction(title: "Congratulations!", )
//        }
        level += 1
        solutions.removeAll(keepingCapacity: true)
        
        loadLevel()
        
        for btn in letterButtons {
            btn.isHidden = false
        }
    }

}

