#!/usr/bin/env python3
"""
Expert System Graph Visualization Tool
Generates various graph representations of the CLIPS expert system
"""

import networkx as nx
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch
import numpy as np
import json

class ExpertSystemVisualizer:
    def __init__(self):
        self.G = nx.DiGraph()
        self.appliance_colors = {
            'fan': '#FF6B6B',
            'washing-machine': '#4ECDC4', 
            'tv': '#45B7D1',
            'control': '#96CEB4',
            'explanation': '#FFEAA7'
        }
        
    def create_rule_dependency_graph(self):
        """Create a graph showing rule dependencies and data flow"""
        
        # Control flow nodes
        self.G.add_node("start-system", type="control", appliance="control")
        self.G.add_node("select-appliance", type="control", appliance="control")
        
        # Fan rules
        fan_rules = [
            "gather-fan-symptoms",
            "fan-no-power-diagnosis", 
            "fan-unusual-noise-diagnosis",
            "fan-slow-running-diagnosis", 
            "fan-excessive-vibration-diagnosis",
            "fan-overheating-diagnosis"
        ]
        
        # Washing machine rules
        washing_rules = [
            "gather-washing-machine-symptoms",
            "washing-machine-no-start-diagnosis",
            "washing-machine-no-agitation-diagnosis", 
            "washing-machine-no-drain-diagnosis",
            "washing-machine-loud-noise-diagnosis",
            "washing-machine-electrical-overload-diagnosis"
        ]
        
        # TV rules
        tv_rules = [
            "gather-tv-symptoms",
            "tv-no-power-diagnosis",
            "tv-no-picture-diagnosis", 
            "tv-no-sound-diagnosis",
            "tv-picture-distortion-diagnosis",
            "tv-random-shutdown-diagnosis"
        ]
        
        # Add fan nodes
        for rule in fan_rules:
            self.G.add_node(rule, type="rule", appliance="fan")
            
        # Add washing machine nodes  
        for rule in washing_rules:
            self.G.add_node(rule, type="rule", appliance="washing-machine")
            
        # Add TV nodes
        for rule in tv_rules:
            self.G.add_node(rule, type="rule", appliance="tv")
            
        # Add explanation nodes
        self.G.add_node("handle-why-question", type="explanation", appliance="explanation")
        self.G.add_node("handle-how-question", type="explanation", appliance="explanation") 
        self.G.add_node("display-diagnosis-results", type="explanation", appliance="explanation")
        
        # Add control flow edges
        self.G.add_edge("start-system", "select-appliance")
        self.G.add_edge("select-appliance", "gather-fan-symptoms")
        self.G.add_edge("select-appliance", "gather-washing-machine-symptoms") 
        self.G.add_edge("select-appliance", "gather-tv-symptoms")
        
        # Add fan flow edges
        for i in range(1, len(fan_rules)):
            self.G.add_edge("gather-fan-symptoms", fan_rules[i])
            
        # Add washing machine flow edges  
        for i in range(1, len(washing_rules)):
            self.G.add_edge("gather-washing-machine-symptoms", washing_rules[i])
            
        # Add TV flow edges
        for i in range(1, len(tv_rules)):
            self.G.add_edge("gather-tv-symptoms", tv_rules[i])
            
        # Add explanation edges
        for appliance_rules in [fan_rules[1:], washing_rules[1:], tv_rules[1:]]:
            for rule in appliance_rules:
                self.G.add_edge(rule, "display-diagnosis-results")
                self.G.add_edge("display-diagnosis-results", "handle-why-question")
                self.G.add_edge("display-diagnosis-results", "handle-how-question")
    
    def plot_rule_dependency_graph(self):
        """Plot the rule dependency graph"""
        plt.figure(figsize=(16, 12))
        
        # Use hierarchical layout
        pos = nx.spring_layout(self.G, k=3, iterations=50, seed=42)
        
        # Adjust positions for better hierarchy
        appliance_positions = {}
        control_y = 0.9
        fan_y = 0.6
        washing_y = 0.3  
        tv_y = 0.0
        explanation_y = -0.3
        
        # Adjust positions by appliance type
        for node in self.G.nodes():
            appliance = self.G.nodes[node]['appliance']
            if appliance == 'control':
                pos[node] = (pos[node][0], control_y)
            elif appliance == 'fan':
                pos[node] = (pos[node][0] - 0.6, fan_y)
            elif appliance == 'washing-machine':
                pos[node] = (pos[node][0], washing_y)
            elif appliance == 'tv':
                pos[node] = (pos[node][0] + 0.6, tv_y)
            elif appliance == 'explanation':
                pos[node] = (pos[node][0], explanation_y)
        
        # Draw nodes by appliance type
        for appliance, color in self.appliance_colors.items():
            nodes = [n for n in self.G.nodes() if self.G.nodes[n]['appliance'] == appliance]
            nx.draw_networkx_nodes(self.G, pos, nodelist=nodes, 
                                 node_color=color, node_size=2000, alpha=0.8)
        
        # Draw edges
        nx.draw_networkx_edges(self.G, pos, edge_color='gray', arrows=True, 
                              arrowsize=20, alpha=0.6, width=1.5)
        
        # Draw labels
        labels = {node: node.replace('-', '\n') for node in self.G.nodes()}
        nx.draw_networkx_labels(self.G, pos, labels, font_size=8, font_weight='bold')
        
        # Create legend
        legend_elements = [mpatches.Patch(color=color, label=appliance.replace('-', ' ').title()) 
                          for appliance, color in self.appliance_colors.items()]
        plt.legend(handles=legend_elements, loc='upper left', bbox_to_anchor=(0, 1))
        
        plt.title("Expert System Rule Dependency Graph", fontsize=16, fontweight='bold')
        plt.axis('off')
        plt.tight_layout()
        plt.savefig('rule_dependency_graph.png', dpi=300, bbox_inches='tight')
        plt.show()

    def create_knowledge_base_graph(self):
        """Create a graph showing the knowledge base structure"""
        KB = nx.DiGraph()
        
        # Templates (Data Structures)
        templates = ['appliance', 'symptom', 'measurement', 'diagnosis', 'explanation', 'question']
        for template in templates:
            KB.add_node(template, type='template', layer=0)
        
        # Facts (Instances)
        facts = ['fan-symptoms', 'washing-machine-symptoms', 'tv-symptoms', 
                'electrical-measurements', 'diagnosis-results', 'explanation-records']
        for i, fact in enumerate(facts):
            KB.add_node(fact, type='fact', layer=1)
            
        # Rules (Inference)
        rule_categories = ['Control Rules', 'Fan Rules', 'Washing Machine Rules', 
                          'TV Rules', 'Explanation Rules']
        for i, rule_cat in enumerate(rule_categories):
            KB.add_node(rule_cat, type='rule_category', layer=2)
        
        # Connect templates to facts
        KB.add_edge('symptom', 'fan-symptoms')
        KB.add_edge('symptom', 'washing-machine-symptoms') 
        KB.add_edge('symptom', 'tv-symptoms')
        KB.add_edge('measurement', 'electrical-measurements')
        KB.add_edge('diagnosis', 'diagnosis-results')
        KB.add_edge('explanation', 'explanation-records')
        
        # Connect facts to rules
        KB.add_edge('fan-symptoms', 'Fan Rules')
        KB.add_edge('washing-machine-symptoms', 'Washing Machine Rules')
        KB.add_edge('tv-symptoms', 'TV Rules') 
        KB.add_edge('electrical-measurements', 'Fan Rules')
        KB.add_edge('electrical-measurements', 'Washing Machine Rules')
        KB.add_edge('electrical-measurements', 'TV Rules')
        KB.add_edge('diagnosis-results', 'Explanation Rules')
        
        return KB
    
    def plot_knowledge_base_graph(self):
        """Plot the knowledge base structure"""
        KB = self.create_knowledge_base_graph()
        
        plt.figure(figsize=(14, 10))
        
        # Create hierarchical layout
        pos = {}
        layer_y = {0: 0.8, 1: 0.5, 2: 0.2}
        layer_counts = {0: 0, 1: 0, 2: 0}
        
        for node in KB.nodes():
            layer = KB.nodes[node]['layer']
            layer_counts[layer] += 1
            
        current_counts = {0: 0, 1: 0, 2: 0}
        for node in KB.nodes():
            layer = KB.nodes[node]['layer']
            total_in_layer = layer_counts[layer]
            x_pos = (current_counts[layer] - (total_in_layer - 1) / 2) * 0.3
            pos[node] = (x_pos, layer_y[layer])
            current_counts[layer] += 1
        
        # Color by type
        type_colors = {'template': '#FFD93D', 'fact': '#6BCF7F', 'rule_category': '#FF6B9D'}
        
        for node_type, color in type_colors.items():
            nodes = [n for n in KB.nodes() if KB.nodes[n]['type'] == node_type]
            nx.draw_networkx_nodes(KB, pos, nodelist=nodes, 
                                 node_color=color, node_size=3000, alpha=0.8)
        
        # Draw edges
        nx.draw_networkx_edges(KB, pos, edge_color='gray', arrows=True, 
                              arrowsize=20, alpha=0.6, width=2)
        
        # Draw labels
        nx.draw_networkx_labels(KB, pos, font_size=10, font_weight='bold')
        
        # Create legend
        legend_elements = [mpatches.Patch(color=color, label=node_type.replace('_', ' ').title()) 
                          for node_type, color in type_colors.items()]
        plt.legend(handles=legend_elements, loc='upper right')
        
        plt.title("Knowledge Base Structure", fontsize=16, fontweight='bold')
        plt.axis('off')
        plt.tight_layout()
        plt.savefig('knowledge_base_graph.png', dpi=300, bbox_inches='tight')
        plt.show()

    def create_decision_tree_graph(self):
        """Create decision tree for one appliance (Fan example)"""
        DT = nx.DiGraph()
        
        # Root
        DT.add_node("Fan Symptoms", type="root")
        
        # Main symptoms
        symptoms = ["No Power", "Unusual Noise", "Slow Running", "Excessive Vibration", "Overheating"]
        
        for symptom in symptoms:
            DT.add_node(symptom, type="symptom")
            DT.add_edge("Fan Symptoms", symptom)
        
        # No Power branch
        DT.add_node("Power at Outlet?", type="question")
        DT.add_edge("No Power", "Power at Outlet?")
        
        DT.add_node("Power Supply Failure\n(0.9)", type="diagnosis")
        DT.add_node("Wires Connected?", type="question")
        DT.add_edge("Power at Outlet?", "Power Supply Failure\n(0.9)", label="No")
        DT.add_edge("Power at Outlet?", "Wires Connected?", label="Yes")
        
        DT.add_node("Loose Wiring\n(0.8)", type="diagnosis")
        DT.add_node("Motor Failure\n(0.7)", type="diagnosis")
        DT.add_edge("Wires Connected?", "Loose Wiring\n(0.8)", label="No")
        DT.add_edge("Wires Connected?", "Motor Failure\n(0.7)", label="Yes")
        
        # Unusual Noise branch
        DT.add_node("Grinding Sound?", type="question")
        DT.add_edge("Unusual Noise", "Grinding Sound?")
        
        DT.add_node("Worn Bearings\n(0.85)", type="diagnosis")
        DT.add_node("Loose Hardware\n(0.9)", type="diagnosis")
        DT.add_edge("Grinding Sound?", "Worn Bearings\n(0.85)", label="Yes")
        DT.add_edge("Grinding Sound?", "Loose Hardware\n(0.9)", label="No")
        
        return DT
    
    def plot_decision_tree(self):
        """Plot decision tree"""
        DT = self.create_decision_tree_graph()
        
        plt.figure(figsize=(16, 12))
        
        # Use hierarchical layout
        pos = nx.nx_agraph.graphviz_layout(DT, prog='dot') if hasattr(nx, 'nx_agraph') else nx.spring_layout(DT, k=3)
        
        # Color by node type
        node_colors = {'root': '#FF9999', 'symptom': '#99CCFF', 'question': '#FFCC99', 'diagnosis': '#99FF99'}
        
        for node_type, color in node_colors.items():
            nodes = [n for n in DT.nodes() if DT.nodes[n]['type'] == node_type]
            if nodes:
                nx.draw_networkx_nodes(DT, pos, nodelist=nodes, 
                                     node_color=color, node_size=2500, alpha=0.8)
        
        # Draw edges
        nx.draw_networkx_edges(DT, pos, edge_color='gray', arrows=True, 
                              arrowsize=20, alpha=0.6, width=1.5)
        
        # Draw labels
        nx.draw_networkx_labels(DT, pos, font_size=9, font_weight='bold')
        
        # Draw edge labels
        edge_labels = nx.get_edge_attributes(DT, 'label')
        nx.draw_networkx_edge_labels(DT, pos, edge_labels, font_size=8)
        
        # Create legend
        legend_elements = [mpatches.Patch(color=color, label=node_type.title()) 
                          for node_type, color in node_colors.items()]
        plt.legend(handles=legend_elements, loc='upper left')
        
        plt.title("Fan Diagnosis Decision Tree", fontsize=16, fontweight='bold')
        plt.axis('off')
        plt.tight_layout()
        plt.savefig('decision_tree_graph.png', dpi=300, bbox_inches='tight')
        plt.show()

    def create_confidence_network(self):
        """Create a network showing confidence levels"""
        CN = nx.Graph()
        
        # Add diagnosis nodes with confidence levels
        diagnoses = {
            "Power Supply Failure": 0.9,
            "Loose Wiring": 0.8, 
            "Motor Failure": 0.7,
            "Worn Bearings": 0.85,
            "Loose Hardware": 0.9,
            "Low Voltage": 0.8,
            "Failing Capacitor": 0.85,
            "Damaged Blades": 0.9,
            "Unbalanced Assembly": 0.75,
            "Motor Overload": 0.85,
            "Poor Ventilation": 0.7
        }
        
        for diagnosis, confidence in diagnoses.items():
            CN.add_node(diagnosis, confidence=confidence, type="diagnosis")
        
        # Add symptom nodes
        symptoms = ["No Power", "Unusual Noise", "Slow Running", "Vibration", "Overheating"]
        for symptom in symptoms:
            CN.add_node(symptom, type="symptom")
        
        # Connect symptoms to diagnoses
        connections = [
            ("No Power", "Power Supply Failure"),
            ("No Power", "Loose Wiring"), 
            ("No Power", "Motor Failure"),
            ("Unusual Noise", "Worn Bearings"),
            ("Unusual Noise", "Loose Hardware"),
            ("Slow Running", "Low Voltage"),
            ("Slow Running", "Failing Capacitor"),
            ("Vibration", "Damaged Blades"),
            ("Vibration", "Unbalanced Assembly"),
            ("Overheating", "Motor Overload"),
            ("Overheating", "Poor Ventilation")
        ]
        
        for symptom, diagnosis in connections:
            CN.add_edge(symptom, diagnosis)
        
        return CN
    
    def plot_confidence_network(self):
        """Plot confidence network with color-coded confidence levels"""
        CN = self.create_confidence_network()
        
        plt.figure(figsize=(14, 10))
        
        pos = nx.spring_layout(CN, k=2, iterations=50)
        
        # Draw symptom nodes
        symptom_nodes = [n for n in CN.nodes() if CN.nodes[n]['type'] == 'symptom']
        nx.draw_networkx_nodes(CN, pos, nodelist=symptom_nodes, 
                             node_color='lightblue', node_size=2000, alpha=0.8)
        
        # Draw diagnosis nodes with confidence-based colors
        diagnosis_nodes = [n for n in CN.nodes() if CN.nodes[n]['type'] == 'diagnosis']
        confidences = [CN.nodes[n]['confidence'] for n in diagnosis_nodes]
        
        # Create color map based on confidence
        colors = plt.cm.RdYlGn([conf for conf in confidences])
        
        nx.draw_networkx_nodes(CN, pos, nodelist=diagnosis_nodes, 
                             node_color=colors, node_size=3000, alpha=0.8)
        
        # Draw edges
        nx.draw_networkx_edges(CN, pos, edge_color='gray', alpha=0.6, width=2)
        
        # Draw labels
        labels = {}
        for node in CN.nodes():
            if CN.nodes[node]['type'] == 'diagnosis':
                conf = CN.nodes[node]['confidence']
                labels[node] = f"{node}\n({conf})"
            else:
                labels[node] = node
                
        nx.draw_networkx_labels(CN, pos, labels, font_size=8, font_weight='bold')
        
        # Create colorbar for confidence levels
        sm = plt.cm.ScalarMappable(cmap=plt.cm.RdYlGn, norm=plt.Normalize(vmin=0.7, vmax=0.95))
        sm.set_array([])
        cbar = plt.colorbar(sm, shrink=0.8)
        cbar.set_label('Confidence Level', rotation=270, labelpad=20)
        
        plt.title("Diagnosis Confidence Network", fontsize=16, fontweight='bold')
        plt.axis('off')
        plt.tight_layout()
        plt.savefig('confidence_network.png', dpi=300, bbox_inches='tight')
        plt.show()

def main():
    """Main function to generate all visualizations"""
    visualizer = ExpertSystemVisualizer()
    
    print("🎨 Generating Expert System Visualizations...")
    
    # Create and plot all graphs
    print("1. Creating Rule Dependency Graph...")
    visualizer.create_rule_dependency_graph()
    visualizer.plot_rule_dependency_graph()
    
    print("2. Creating Knowledge Base Structure...")
    visualizer.plot_knowledge_base_graph()
    
    print("3. Creating Decision Tree...")
    visualizer.plot_decision_tree()
    
    print("4. Creating Confidence Network...")
    visualizer.plot_confidence_network()
    
    print("✅ All visualizations generated successfully!")
    print("📁 Files saved:")
    print("   - rule_dependency_graph.png")
    print("   - knowledge_base_graph.png") 
    print("   - decision_tree_graph.png")
    print("   - confidence_network.png")

if __name__ == "__main__":
    main()
