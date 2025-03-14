/**
 * Unit Tests for Reactive State System
 */

import { expect } from 'chai';
import { reactive, StateManager } from '../assets/js/components/core/reactive_state';

describe('Reactive State System', () => {
  describe('reactive()', () => {
    it('should make an object reactive', () => {
      const changes = [];
      const accesses = [];
      
      const original = { count: 0, nested: { value: 'test' } };
      const reactiveObj = reactive(original, {
        onChange: (path, newValue) => changes.push({ path, newValue }),
        onAccess: (path) => accesses.push(path)
      });
      
      // Test property access tracking
      const value = reactiveObj.count;
      expect(accesses).to.include('count');
      
      // Test property change tracking
      reactiveObj.count = 1;
      expect(changes).to.deep.include({ path: 'count', newValue: 1 });
      
      // Test nested reactivity
      reactiveObj.nested.value = 'updated';
      expect(changes).to.deep.include({ path: 'nested.value', newValue: 'updated' });
    });
    
    it('should not wrap primitive values', () => {
      const reactiveNumber = reactive(42);
      expect(reactiveNumber).to.equal(42);
      
      const reactiveString = reactive('test');
      expect(reactiveString).to.equal('test');
      
      const reactiveNull = reactive(null);
      expect(reactiveNull).to.equal(null);
    });
    
    it('should handle property deletion', () => {
      const changes = [];
      const original = { a: 1, b: 2 };
      const reactiveObj = reactive(original, {
        onChange: (path, newValue, oldValue) => changes.push({ path, newValue, oldValue })
      });
      
      delete reactiveObj.a;
      expect(original).to.not.have.property('a');
      expect(changes).to.deep.include({ path: 'a', newValue: undefined, oldValue: 1 });
    });
  });
  
  describe('StateManager', () => {
    let stateManager;
    
    beforeEach(() => {
      stateManager = new StateManager();
    });
    
    it('should create reactive state', () => {
      const state = stateManager.defineState({ count: 0 });
      expect(state.count).to.equal(0);
      
      state.count = 1;
      expect(state.count).to.equal(1);
    });
    
    it('should handle computed properties', () => {
      const state = stateManager.defineState({ a: 1, b: 2 });
      
      // Define computed property that depends on a and b
      stateManager.compute('sum', ['a', 'b'], (state) => state.a + state.b);
      
      expect(state.sum).to.equal(3);
      
      // Update dependencies
      state.a = 2;
      expect(state.sum).to.equal(4);
      
      state.b = 3;
      expect(state.sum).to.equal(5);
    });
    
    it('should support nested state updates', () => {
      const state = stateManager.defineState({
        user: {
          profile: {
            name: 'John',
            age: 30
          }
        }
      });
      
      state.user.profile.name = 'Jane';
      expect(state.user.profile.name).to.equal('Jane');
    });
    
    it('should track state history when enabled', () => {
      const historyManager = new StateManager({ historyEnabled: true });
      const state = historyManager.defineState({ count: 0 });
      
      state.count = 1;
      state.count = 2;
      
      const history = historyManager.getHistory();
      expect(history).to.have.length(2);
      expect(history[0].path).to.equal('count');
      expect(history[0].newValue).to.equal(1);
      expect(history[1].newValue).to.equal(2);
    });
    
    it('should support batch updates', () => {
      let updateCount = 0;
      const stateManager = new StateManager({
        updateCallback: () => updateCount++
      });
      
      const state = stateManager.defineState({ a: 1, b: 2, c: 3 });
      
      // Single updates should trigger update callback each time
      state.a = 10;
      state.b = 20;
      expect(updateCount).to.equal(2);
      
      // Batch updates should only trigger once
      stateManager.batch(() => {
        state.a = 100;
        state.b = 200;
        state.c = 300;
      });
      
      expect(updateCount).to.equal(3);
    });
    
    it('should support watchers', () => {
      const state = stateManager.defineState({ count: 0 });
      let watcherCalled = 0;
      
      stateManager.watch('count', (newValue, oldValue) => {
        watcherCalled++;
        expect(oldValue).to.equal(0);
        expect(newValue).to.equal(1);
      });
      
      state.count = 1;
      expect(watcherCalled).to.equal(1);
    });
  });
  
  describe('Edge Cases', () => {
    it('should handle circular references', () => {
      const obj = { name: 'circular' };
      obj.self = obj; // Create circular reference
      
      const reactiveObj = reactive(obj);
      expect(reactiveObj.name).to.equal('circular');
      expect(reactiveObj.self).to.equal(reactiveObj);
    });
    
    it('should handle Arrays properly', () => {
      const state = new StateManager().defineState({ items: [1, 2, 3] });
      
      state.items.push(4);
      expect(state.items).to.have.length(4);
      expect(state.items[3]).to.equal(4);
      
      state.items[0] = 10;
      expect(state.items[0]).to.equal(10);
    });
    
    it('should handle deeply nested updates', () => {
      const state = new StateManager().defineState({
        level1: {
          level2: {
            level3: {
              level4: {
                value: 'deep'
              }
            }
          }
        }
      });
      
      state.level1.level2.level3.level4.value = 'updated';
      expect(state.level1.level2.level3.level4.value).to.equal('updated');
    });
  });
}); 