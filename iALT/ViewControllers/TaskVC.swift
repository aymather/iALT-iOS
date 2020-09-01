//
//  TaskVC.swift
//  iALT
//
//  Created by Alec Mather on 8/6/20.
//  Copyright © 2020 Alec Mather. All rights reserved.
//

import UIKit
import CoreHaptics

class TaskVC: UIViewController {
    
    // Lock orientation
    override var shouldAutorotate: Bool { return false }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .landscapeLeft }
    
    // MARK: - Properties
    private var trialnum = 0
    private var stimDisplayTime = DispatchTime.now()
    private var hasResponded = false
    private var isBlockFeedbackDone = false
    private var countdownOver = false
    private let vibrator = Vibrator()
    private var data: ParticipantData
    private var settings: Settings
    private var columns: Columns
    private var trialseq: Trialseq
    private var time: Time
    
    // MARK: - Init
    init(data: ParticipantData, settings: Settings, columns: Columns, trialseq: Trialseq) {
        self.data = data
        self.settings = settings
        self.columns = columns
        self.trialseq = trialseq
        self.time = Time(trials: self.trialseq.seq.count)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let errorMessage: UILabel = {
     
        let label = UILabel()
        label.text = "Error initializing"
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
        
    }()
    
    private let startButton: UIButton = {
       
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        button.layer.cornerRadius = 12
        return button
        
    }()
    
    // Response buttons
    private lazy var leftResponse: UIButton = self.createResponseButton()
    private lazy var rightResponse: UIButton = self.createResponseButton()
    
    // Screen text
    private lazy var centerText: UILabel = self.createScreenText(text: "3...")
    private lazy var leftText: UILabel = self.createScreenText(text: "W")
    private lazy var rightText: UILabel = self.createScreenText(text: "W")
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.forceLandscape()
        
        addTargets()
        setupLayout()
        constraints()
        vibrator.prepare()
    }
    
    private func createResponseButton() -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 12
        button.isEnabled = false
        return button
    }
    
    private func createScreenText(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 46, weight: .medium)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }
    
    private func displayError() {
        view.addSubview(errorMessage)
        errorMessage.center()
    }
    
    private func addTargets() {
        startButton.addTarget(self, action: #selector(self._handleStartButton), for: .touchUpInside)
        leftResponse.addTarget(self, action: #selector(self._handleLeftResp), for: .touchDown)
        rightResponse.addTarget(self, action: #selector(self._handleRightResp), for: .touchDown)
    }
    
    private func setupLayout() {
        view.addSubview(startButton)
        view.addSubview(centerText)
        view.addSubview(rightText)
        view.addSubview(leftText)
        view.addSubview(leftResponse)
        view.addSubview(rightResponse)
        
        centerText.isHidden = true
        leftText.isHidden = true
        rightText.isHidden = true
    }
    
    private func constraints() {
        
        startButton.center()
        startButton.size(width: 200, height: 120)
        
        centerText.translatesAutoresizingMaskIntoConstraints = false
        centerText.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
        centerText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        leftText.translatesAutoresizingMaskIntoConstraints = false
        leftText.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
        leftText.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -150).isActive = true
        
        rightText.translatesAutoresizingMaskIntoConstraints = false
        rightText.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
        rightText.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 150).isActive = true
        
        leftResponse.anchor(top: nil, left: view.safeAreaLayoutGuide.leadingAnchor, right: nil, bottom: view.bottomAnchor, padding: .init(top: 0, left: 50, bottom: 10, right: 0))
        leftResponse.size(width: 160, height: 100)
        rightResponse.anchor(top: nil, left: nil, right: view.safeAreaLayoutGuide.trailingAnchor, bottom: view.bottomAnchor, padding: .init(top: 0, left: 0, bottom: 10, right: 50))
        rightResponse.size(width: 160, height: 100)
        
    }
    
    private func buttons(isEnabled bool: Bool) {
        leftResponse.isEnabled = bool
        rightResponse.isEnabled = bool
    }
    
}

// MARK: - Main Control Functions
extension TaskVC {
    
    // MARK: - Start function (entrance point for the experiment)
    private func run() {
        
        DispatchQueue.global(qos: .utility).async {
            
            let expstart = DispatchTime.now()
            self.time.expStart = expstart.uptimeNanoseconds
                
            // Block trials loop
            for trial in 0...self.trialseq.seq.count - 1 {
                
                let block = Int(self.trialseq.seq[(trial, self.columns.block)])
                
                if trial == 0 || self.trialseq.seq[(trial - 1, self.columns.block)] != self.trialseq.seq[(trial, self.columns.block)] {
                    // Play countdown
                    self.playIntro()
                    
                    let blockstart = DispatchTime.now()
                    self.time.m[(trial, self.time.blockstart)] = blockstart.uptimeNanoseconds
                }

                // Get the stimulus
                var stim: String
                if self.trialseq.seq[(trial, self.columns.go)] == 0 {
                    stim = self.settings.general.buttonMap["go"]!
                } else {
                    stim = self.settings.general.buttonMap["nogo"]!
                }

                // Get the deadline
                let deadline = self.trialseq.seq[(trial, self.columns.deadline)] + self.settings.durations.fixation

                // Prep the stimulus to the appropriate side
                let side = self.trialseq.seq[(trial, self.columns.side)]
                var stimText: UILabel
                if side == 1 { stimText = self.leftText } else { stimText = self.rightText }
                DispatchQueue.main.async { stimText.text = stim }

                // Prep novelty
                let isNovelty = self.trialseq.seq[(trial, self.columns.nov)]

                // Prep center stimuli
                DispatchQueue.main.async {
                    self.centerText.textColor = .white
                    self.centerText.text = "+"
                }

                // Exit code for trial duration
                var isTrue = true

                /// Event 1: Display fixation
                let starttime = DispatchTime.now()
                DispatchQueue.main.async {
                    let starttime2FixationDispatch = DispatchTime.now()
                    self.centerText.isHidden = false
                    let starttime2FixationDispatchFinished = DispatchTime.now()
                    
                    self.time.m[(trial, self.time.starttime2FixationDispatch)] = starttime2FixationDispatch.uptimeNanoseconds
                    self.time.m[(trial, self.time.starttime2FixationDispatchFinished)] = starttime2FixationDispatchFinished.uptimeNanoseconds
                    
                }
                
                self.time.m[(trial, self.time.starttime)] = starttime.uptimeNanoseconds
                
                /// Go into trial loop
                var hasBeenPresented = false
                var noveltyPlayed = false
                while isTrue == true {

                    /// Present stimulus after fixation duration
                    if !hasBeenPresented && (Double(DispatchTime.now().uptimeNanoseconds - starttime.uptimeNanoseconds) / 1000000000) >= self.settings.durations.fixation {
                        DispatchQueue.main.async {
                            let stimDisplayDispatch = DispatchTime.now()
                            stimText.isHidden = false
                            let stimDisplayDispatchFinished = DispatchTime.now()
                            self.buttons(isEnabled: true)
                            
                            self.time.m[(trial, self.time.stimDisplayDispatch)] = stimDisplayDispatch.uptimeNanoseconds
                            self.time.m[(trial, self.time.stimDisplayDispatchFinished)] = stimDisplayDispatchFinished.uptimeNanoseconds
                        }
                        hasBeenPresented = true
                    }

                    /// Play novel sound if novel trial and 50ms delay has been reached
                    if isNovelty == 1 && !noveltyPlayed && (Double(DispatchTime.now().uptimeNanoseconds - starttime.uptimeNanoseconds) / 1000000000) >= (self.settings.durations.fixation + self.settings.durations.delay) {
                        let noveltyOnset = DispatchTime.now()
                        self.vibrator.play()
                        let noveltyOnsetFinished = DispatchTime.now()
                        
                        self.time.m[(trial, self.time.noveltyOnset)] = noveltyOnset.uptimeNanoseconds
                        self.time.m[(trial, self.time.noveltyOnsetFinished)] = noveltyOnsetFinished.uptimeNanoseconds
                        
                        noveltyPlayed = true
                    }

                    /// Exit after deadline or if we got a response
                    if self.hasResponded || (Double(DispatchTime.now().uptimeNanoseconds - starttime.uptimeNanoseconds) / 1000000000) >= deadline {
                        isTrue = false
                    }
                }
                
                /// Reset hasResponded bool
                self.hasResponded = false

                /// Post Trial clean-up

                /// Hide all stimuli
                DispatchQueue.main.async {
                    let stimDisplayEndDispatch = DispatchTime.now()
                    self.centerText.isHidden = true
                    self.rightText.isHidden = true
                    self.leftText.isHidden = true
                    let stimDisplayEndDispatchFinished = DispatchTime.now()
                    
                    self.time.m[(trial, self.time.stimDisplayEndDispatch)] = stimDisplayEndDispatch.uptimeNanoseconds
                    self.time.m[(trial, self.time.stimDisplayEndDispatchFinished)] = stimDisplayEndDispatchFinished.uptimeNanoseconds
                }
                
                // Code Responses
                /// Go trials
                if self.trialseq.seq[(trial, self.columns.go)] == 1 {

                    if self.trialseq.seq[(trial, self.columns.resp)] != 0 && self.trialseq.seq[(trial, self.columns.resp)] == self.trialseq.seq[(trial, self.columns.side)] {
                        /// Correct
                        self.trialseq.seq[(trial, self.columns.acc)] = 1
                    } else if self.trialseq.seq[(trial, self.columns.resp)] != 0 && self.trialseq.seq[(trial, self.columns.resp)] != self.trialseq.seq[(trial, self.columns.side)] {
                        /// Error
                        self.trialseq.seq[(trial, self.columns.acc)] = 2
                    } else if self.trialseq.seq[(trial, self.columns.resp)] == 0 {
                        /// Miss
                        self.trialseq.seq[(trial, self.columns.acc)] = 99
                    }

                } else {
                    /// Nogo trials

                    if self.trialseq.seq[(trial, self.columns.resp)] == 0 {
                        /// Successful stop
                        self.trialseq.seq[(trial, self.columns.acc)] = 4
                    } else {
                        /// Failed stop
                        self.trialseq.seq[(trial, self.columns.acc)] = 3
                    }
                }

                /// If we have a "miss" then display "Too Slow!" feedback
                if self.trialseq.seq[(trial, self.columns.acc)] == 99 {
                    // Display "Too Slow!" feedback
                    DispatchQueue.main.async {
                        let feedbackDispatch = DispatchTime.now()
                        self.centerText.text = "Too Slow!"
                        self.centerText.textColor = .red
                        self.centerText.isHidden = false
                        let feedbackDispatchFinished = DispatchTime.now()
                        
                        self.time.m[(trial, self.time.feedbackDispatch)] = feedbackDispatch.uptimeNanoseconds
                        self.time.m[(trial, self.time.feedbackDispatchFinished)] = feedbackDispatchFinished.uptimeNanoseconds
                    }

                    var isFeedbackDone = false
                    let now = DispatchTime.now()
                    while !isFeedbackDone {
                        if (Double(DispatchTime.now().uptimeNanoseconds - now.uptimeNanoseconds) / 1000000000) >= self.settings.durations.feedback {
                            DispatchQueue.main.async {
                                let feedbackDispatchEnd = DispatchTime.now()
                                self.centerText.isHidden = true
                                let feedbackDispatchEndFinished = DispatchTime.now()
                                
                                self.time.m[(trial, self.time.feedbackDispatchEnd)] = feedbackDispatchEnd.uptimeNanoseconds
                                self.time.m[(trial, self.time.feedbackDispatchEndFinished)] = feedbackDispatchEndFinished.uptimeNanoseconds
                            }
                            isFeedbackDone = true
                        }
                    }
                }
                
                /// Adjust deadline for next trial | If we get a miss, slow it down, if we get 5 accurates in a row, speed it up
                if self.trialseq.seq[(trial, self.columns.acc)] == 99 {
                    let deadline = self.trialseq.seq[(trial, self.columns.deadline)] + self.settings.durations.deadline_adjustment
                    self.trialseq.fillRows(column: self.columns.deadline, from: (trial + 1), to: self.trialseq.seq.count, with: deadline)
                } else if self.trialseq.seq[(trial, self.columns.acc)] == 1 && self.trialseq.isPast3GoTrialsAccurate(trialnum: trial) {
                    let deadline = self.trialseq.seq[(trial, self.columns.deadline)] - self.settings.durations.deadline_adjustment
                    self.trialseq.fillRows(column: self.columns.deadline, from: (trial + 1), to: self.trialseq.seq.count, with: deadline)
                }
                
                /// Fill the rest of the time left with ITI
                var isDone = true
                let end = DispatchTime.now()
                while isDone == true {
                    if (Double(DispatchTime.now().uptimeNanoseconds - end.uptimeNanoseconds) / 1000000000) >= self.settings.durations.iti {
                        let trialEnd = DispatchTime.now()
                        self.time.m[(trial, self.time.endtime)] = trialEnd.uptimeNanoseconds
                        isDone = false
                    }
                }
                
                if trial == self.settings.general.blocks {
                    let blockend = DispatchTime.now()
                    self.time.m[(trial, self.time.blockend)] = blockend.uptimeNanoseconds
                }
                
                if trial + 1 == self.trialseq.seq.count || self.trialseq.seq[(trial, self.columns.block)] != self.trialseq.seq[(trial + 1, self.columns.block)] {
                    // Display block feedback
                    self.blockFeedback(blocknum: block)
                    
                    // If end of experiment, thank participant and exit
                    if block == self.settings.general.blocks {
                        self.end()
                    }
                }
                
                // Add trial
                self.trialnum += 1
            }
            
        }
        
    }
    
    // MARK: - Intro Countdown 3...1
    @objc private func playIntro() {
        
        // If we have any gesture recognizers on center text, remove them
        // They get attached during block feedback to move into next block
        
        DispatchQueue.main.async {
            self.centerText.isUserInteractionEnabled = false
            self.centerText.font = UIFont.systemFont(ofSize: 46, weight: .medium)
            self.centerText.text = "3"
            self.centerText.isHidden = false
            self.leftResponse.isHidden = false
            self.rightResponse.isHidden = false
            self.startButton.isHidden = true
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                guard let value = Int(self.centerText.text!) else { return }
                if value == 1 {
                    timer.invalidate()
                    self.countdownOver = true
                } else {
                    self.centerText.text = "\(value - 1)"
                }
            }
        }
        
        while !self.countdownOver { }
        
        self.countdownOver = false
        
    }
    
    // MARK: - End Experiment (exit point for the experiment)
    private func end() {
        DispatchQueue.main.async {
            self.centerText.text = "Thank you for participating! :)"
            let g = UITapGestureRecognizer(target: self, action: #selector(self._handleExitExperiment))
            g.numberOfTapsRequired = 1
            self.centerText.addGestureRecognizer(g)
            self.centerText.isUserInteractionEnabled = true
        }
        let expend = DispatchTime.now()
        self.time.expEnd = expend.uptimeNanoseconds
    }
    
    // MARK: - Block Feedback
    private func blockFeedback(blocknum: Int) {
        
        print("Block feedback")
        
        DispatchQueue.main.async {
            self.leftResponse.isHidden = true
            self.rightResponse.isHidden = true
            self.centerText.isHidden = true
        }
        
        let block = self.trialseq.getBlock(blocknum: Double(blocknum))
        let go = Matlab.getRows(matrix: block, column: self.columns.go, is: 1)
        let nogo = Matlab.getRows(matrix: block, column: self.columns.go, is: 0)

        let succ_go_trials = Matlab.getRows(matrix: block, column: self.columns.acc, is: 1)
        let succ_go_rts = Matlab.getRows(matrix: succ_go_trials, column: self.columns.rt)
        
        let rt = Matlab.mean(array: succ_go_rts)
        let error_trials = Matlab.getRows(matrix: block, column: self.columns.acc, is: Double(2))
        let error_percent = (Double(error_trials.count) / Double(go.count)) * 100
        let miss_trials = Matlab.getRows(matrix: block, column: self.columns.acc, is: Double(99))
        let miss_percent = (Double(miss_trials.count) / Double(go.count)) * 100
        let succstop_trials = Matlab.getRows(matrix: block, column: self.columns.acc, is: Double(4))
        let succstop_percent = (Double(succstop_trials.count) / Double(nogo.count)) * 100
        let failstop_trials = Matlab.getRows(matrix: block, column: self.columns.acc, is: Double(3))
        let failstop_percent = (Double(failstop_trials.count) / Double(nogo.count)) * 100

        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .medium)
        ]
        let attribString = NSMutableAttributedString()

        attribString.append(NSAttributedString(string: "Block Feedback: \(blocknum) / \(settings.general.blocks)", attributes: attributes))
        attribString.append(NSAttributedString(string: "\n\nRT: \(String(format: "%.2f", rt))ms", attributes: attributes))
        attribString.append(NSAttributedString(string: "\n\nSuccessful Stops: \(String(format: "%.2f", succstop_percent))%", attributes: attributes))
        attribString.append(NSAttributedString(string: "\n\nMiss: \(String(format: "%.2f", miss_percent))%", attributes: attributes))
        attribString.append(NSAttributedString(string: "\n\nError: \(String(format: "%.2f", error_percent))%", attributes: attributes))
        attribString.append(NSAttributedString(string: "\n\nFailed Stops: \(String(format: "%.2f", failstop_percent))%", attributes: attributes))
        
        DispatchQueue.main.async {
            self.centerText.attributedText = attribString
            self.centerText.isHidden = false
        }
        
        let now = DispatchTime.now()
        var hasBeenEnabled = false
        while !self.isBlockFeedbackDone {
            
            if !hasBeenEnabled && Double((DispatchTime.now().uptimeNanoseconds - now.uptimeNanoseconds) / 1000000000) >= 3 {
                DispatchQueue.main.async {
                    let g = UITapGestureRecognizer(target: self, action: #selector(self.endBlockFeedback))
                    self.centerText.addGestureRecognizer(g)
                    g.numberOfTapsRequired = 1
                    self.centerText.isUserInteractionEnabled = true
                }
                hasBeenEnabled = true
            }
            
        }
        
        // Reset center text
        DispatchQueue.main.async {
            self.centerText.font = UIFont.systemFont(ofSize: 46, weight: .medium)
            self.centerText.text = "+"
        }
        
        // Reset flag for next block feedback
        self.isBlockFeedbackDone = false
        
    }
    
}

// MARK: - Callback functions
extension TaskVC {
    
    @objc private func endBlockFeedback() {
        self.isBlockFeedbackDone = true
    }
    
    @objc private func _handleExitExperiment() {
        self.dismiss(animated: true)
    }
    
    @objc private func _handleStartButton() {
        DispatchQueue.main.async {
            self.startButton.isHidden = true
            self.run()
        }
    }
    
    @objc private func _handleLeftResp() {
        let end = DispatchTime.now()
        
        // Disable buttons
        self.buttons(isEnabled: false)
        
        // Put in response side
        self.trialseq.seq[(trialnum, columns.resp)] = 1
        
        // Calculate rt
        self.trialseq.seq[(trialnum, columns.rt)] = Double((end.uptimeNanoseconds - self.stimDisplayTime.uptimeNanoseconds) / 1000000) // in ms
        
        // Let the trial loop know that the response has been recorded
        self.hasResponded = true
    }
    
    @objc private func _handleRightResp() {
        let end = DispatchTime.now()
        
        // Disable buttons
        self.buttons(isEnabled: false)
        
        // Put in response side
        self.trialseq.seq[(trialnum, columns.resp)] = 2
        
        // Calculate rt
        self.trialseq.seq[(trialnum, columns.rt)] = Double((end.uptimeNanoseconds - self.stimDisplayTime.uptimeNanoseconds) / 1000000) // in ms
        
        // Let the trial loop know that the response has been recorded
        self.hasResponded = true
    }
    
}
