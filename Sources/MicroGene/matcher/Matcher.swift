//
//  Matcher.swift
//  MicroGene
//
//  Created by Ilya Mikhaltsou on 10/13/17.
//

import Foundation

public class Matcher: Matching {
    // struct partial { known_bindings[binding.anyHashable: (binding, path, value)] }
    // var pathexpressionstree[expression: (params(matchableType, onMatch, partials[partial]), binding)]
    // func match (value?, path) {
    //      let list[(params, binding)] = find in pathexpressionstreen shffled then sorted by params.matchableType.priority & binding.count descending
    //      for (params, binding) in list {
    //          if type(value) != binding.type { abort }
    //          params.partials.append(partial())
    //          for partial in params.partials {
    //              if let v = value, partial.known_bindings[binding.anyHashable] == nil {
    //                  partial.known_bindings[binding.anyHashable] = (binding, path, v)
    //              } else if value == nil,
    //                let (_, partpath, _) == partial.known_bindings[binding.anyHashable] != nil,
    //                partpath == path {
    //                  partial.known_bindings[binding.anyHashable] = nil
    //              }
    //          }
    //          if fullMatch(partials) { break }
    //          params.paritals = params.partials.filter { bindings in bindings.count != 0 }
    //      }
    // }
    // func fullMatch(params) {
    //      let fullSet == Set(params.matchableType.bindings.map(_.anyHashable))
    //      let found = params.partials.filter { partial in
    //          return partial.known_bindings.keys == fullSet
    //      }
    //      for partial in found {
    //          let potential = matchableType.init()
    //          for closure in partial.known_bindings.values { closure(&potential) }
    //          if potential.match() {
    //              params.onMatch(potential)
    //              return true
    //          }
    //      }
    //      return false
    // }
    //

    struct BindingInformation {
        var binding: AnyVariableBinding
        var path: Path
        var value: Storable
    }

    private struct PartialBinding {
        var knownBindings: [AnyHashable: BindingInformation] = [:]
    }

    private func findMatches(for path: Path) {
        
    }

    func register<T>(_ matchableType: T.Type, onMatch matchClosure: (T) -> ()) where T: Matchable {

    }

    func match(_ value: Storable, at path: Path) {
        
    }

}
