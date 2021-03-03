//
//  ViewController.swift
//  catch_jellyfsh
//
//  Created by A4-iMAC01 on 17/02/2021.
//

import UIKit
import ARKit
import Each
class ViewController: UIViewController {
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var enemiesLabel: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var labelTemp: UILabel!
    var temp = Each(1).seconds
    var cuenta = 10
    let config = ARWorldTrackingConfiguration()
    let boss = "vasija"
    var list = [
        "Jellyfish",
        "balon"
    ]
    
    let enemiesPerLevel = 2
    
    var _enemiesLeft = 0
    var enemiesLeft:Int{
        get{
            return _enemiesLeft
        }
        set(i){
            if (i == 0){
                _enemiesLeft = enemiesPerLevel
                level += 1
            }else{
                _enemiesLeft = i
            }
            self.enemiesLabel.text = "Enemigos:\(_enemiesLeft)"
        }
        
    }
    var _level:Int = 0
    var level:Int{
        get{
            return _level
        }
        set(i){
            _level = i
            levelLabel.text = "Level:\(_level)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.session.run(config)
        let tap:UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        self.sceneView.addGestureRecognizer(tap)
    }
    @objc func handleTap(sender: UITapGestureRecognizer) -> Void {
        print("You Tapped")
        let sceneViewTappedOn:SCNView = sender.view as! SCNView
        let touchCoordinates:CGPoint = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        if hitTest.isEmpty {
            print("No has tocado nada")
        }else{
            let results:SCNHitTestResult? = hitTest.first;
            guard let node = results?.node else {return}
            print("Has tocado el objeto \(node.name ?? "Unknown Node")")
            if node.animationKeys.isEmpty,node.name != nil {
                enemiesLeft -= 1
                SCNTransaction.begin()
                self.animateNode(node: node)
                SCNTransaction.completionBlock = {
                    node.removeFromParentNode()
                    self.addNode()
                    self.reiniciaTiempo()
                    
                }
                SCNTransaction.commit()
            }
        }
    }
    
    @IBAction func restart(_ sender: Any) {
        self.restartButton.isEnabled = false
        self.deleteAllNodes()
        self.reiniciaTiempo()
        self.resetGameStats()
        self.addNode()
        self.setTiempo()
    }
    @IBAction func play(_ sender: Any) {
        self.addNode()
        self.setTiempo()
        self.resetGameStats()
        self.playButton.isEnabled = false
    }
    func resetGameStats(){
        level = 1
        enemiesLeft = enemiesPerLevel
    }
    
    func deleteAllNodes() {
        for (_,x) in sceneView.scene.rootNode.childNodes.enumerated(){
            x.removeFromParentNode()
        }
    }
    func reiniciaTiempo() -> Void {
        self.cuenta = 10
        self.labelTemp.text = String(self.cuenta)
    }
    func setTiempo(){
        self.temp.perform{ () -> NextStep in
            self.cuenta -= 1
            self.labelTemp.text = String(self.cuenta)
            if self.cuenta == 0{
                self.labelTemp.text = "Has perdido"
                self.restartButton.isEnabled = true
                self.deleteAllNodes()
                return .stop
            }
            return .continue
        }
    }
    func addNode() {
        //If level is 5,10,15, etc spawns a Boss
        let name:String = level%5==0 ? boss : list[Int.random(in: 0...list.count-1)]
        let jellyScene = SCNScene(named: "art.scnassets/\(name).scn")
        let jellyNode = jellyScene?.rootNode.childNode(withName: name, recursively: false)
        jellyNode?.position = SCNVector3(Float.random(in: -1...1),Float.random(in: -1...1),Float.random(in: -1...1))
        jellyNode?.name = name.capitalized
        self.sceneView.scene.rootNode.addChildNode(jellyNode!)
    }
    func animateNode(node:SCNNode){
        let spin = CABasicAnimation(keyPath: "position")
        let pos = node.presentation.position
        spin.fromValue = pos
        spin.toValue = SCNVector3(pos.x+1, pos.y, pos.z-1)
        spin.duration = 0.07
        spin.autoreverses = true
        spin.repeatCount = 5
        node.addAnimation(spin, forKey: "position")
    
    }
}

