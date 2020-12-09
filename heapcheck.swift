import Foundation
struct Heap {
    private var elements = [Int]()
    private var sort: (_ left: Int, _ right: Int) -> Bool
    
    init(elements: [Int],  sort: @escaping (_ left: Int, _ right: Int) -> Bool) {
        self.elements = elements
        self.sort = sort
        
        for index in stride(from: elements.count/2 - 1, through: 0, by: -1) {
            siftDown(at: index)
        }
    }
    
    var peek: Int? {
        return elements.first
    }
    
    var size: Int {
        return elements.count
    }
    
    mutating func push(element: Int) {
        defer {
            siftUp(at: elements.count-1)
        }
        
        elements.append(element)
    }
    
    mutating func pop() -> Int? {
        guard !elements.isEmpty else { return nil }
        
        elements.swapAt(0, elements.count-1)
        defer {
            siftDown(at: 0)
        }  
        return elements.removeLast()
    }
    
    private func parent(of index: Int) -> Int { return (index - 1) / 2 }
    private func leftChild(of index: Int) -> Int { return index * 2 + 1}
    private func rightChild(of index: Int) -> Int { return index * 2 + 2 }
    
    private mutating func siftDown(at index: Int) {
        var parent = index
        while true {
            let left = leftChild(of: parent)
            let right = rightChild(of: parent)
            var candidate = parent
            
            if left < elements.count && sort(elements[left], elements[candidate]) {
                candidate = left
            }
            
            if right < elements.count && sort(elements[right], elements[candidate]) {
                candidate = right
            }
            
            if candidate == parent {
                return
            }
            
            elements.swapAt(candidate, parent)
            parent = candidate
        }
    } 
    
    private mutating func siftUp(at index: Int) {
        var current = index
        var parent = self.parent(of: current)
        
        while current > 0 && sort(elements[current], elements[parent]) {
            elements.swapAt(current, parent)
            current = parent
            parent = self.parent(of: current)
        }
    }
}
func f(n: Int, values :[Int]) -> [Int] {
     var heap = Heap(elements: [0], sort: { $0 < $1 })
     for value in values{
     heap.push(element: value)
     if heap.size > n{
         heap.pop()
     }
     }
     return heap.peek
}
print(f(n :2, values : [0,5,-5,10,-10]))
