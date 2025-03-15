/**
 * Timeline Component Tests
 * ------------------------
 * Tests for the Timeline component that provides a chronological event visualization.
 */

import { TimelineComponent } from '../../../assets/js/components/timeline';
import { fireEvent } from '@testing-library/dom';
import sinon from 'sinon';

describe('Timeline Component', () => {
  let testContainer;
  let component;
  
  const mockEvents = [
    { id: 'event1', title: 'Event 1', timestamp: '2024-03-14T10:00:00Z', type: 'info' },
    { id: 'event2', title: 'Event 2', timestamp: '2024-03-14T11:00:00Z', type: 'success' },
    { id: 'event3', title: 'Event 3', timestamp: '2024-03-14T12:00:00Z', type: 'warning' }
  ];
  
  beforeEach(() => {
    testContainer = document.createElement('div');
    document.body.appendChild(testContainer);
    
    // Create the timeline element
    const timelineElement = document.createElement('div');
    timelineElement.className = 'timeline';
    timelineElement.setAttribute('data-orientation', 'vertical');
    testContainer.appendChild(timelineElement);
    
    // Initialize the component
    component = new TimelineComponent(timelineElement, { events: mockEvents });
  });
  
  afterEach(() => {
    if (component) {
      component.destroy();
    }
    
    if (testContainer && testContainer.parentNode) {
      testContainer.parentNode.removeChild(testContainer);
    }
    
    sinon.restore();
  });
  
  describe('Initialization', () => {
    it('initializes with the correct options', () => {
      expect(component).toBeDefined();
      expect(component.element).toBeDefined();
      expect(component.options.events).toEqual(mockEvents);
      expect(component.options.orientation).toBe('vertical');
    });
    
    it('creates timeline structure', () => {
      component.initialize();
      
      const events = document.querySelectorAll('.timeline-event');
      expect(events.length).toBe(3);
      
      const connectors = document.querySelectorAll('.timeline-connector');
      expect(connectors.length).toBe(2); // Number of events - 1
    });
    
    it('sets default options when not provided', () => {
      const defaultElement = document.createElement('div');
      defaultElement.className = 'timeline';
      testContainer.appendChild(defaultElement);
      
      const defaultComponent = new TimelineComponent(defaultElement);
      
      expect(defaultComponent.options.events).toEqual([]);
      expect(defaultComponent.options.orientation).toBe('vertical');
      expect(defaultComponent.options.showTime).toBe(true);
      
      defaultComponent.destroy();
    });
  });
  
  describe('Event Management', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('adds new event', () => {
      const newEvent = {
        id: 'event4',
        title: 'Event 4',
        timestamp: '2024-03-14T13:00:00Z',
        type: 'info'
      };
      
      component.addEvent(newEvent);
      
      const events = document.querySelectorAll('.timeline-event');
      expect(events.length).toBe(4);
      expect(events[3].getAttribute('data-event-id')).toBe('event4');
    });
    
    it('removes event', () => {
      component.removeEvent('event2');
      
      const events = document.querySelectorAll('.timeline-event');
      expect(events.length).toBe(2);
      expect(Array.from(events).map(e => e.getAttribute('data-event-id')))
        .toEqual(['event1', 'event3']);
    });
    
    it('updates event', () => {
      component.updateEvent('event1', {
        title: 'Updated Event',
        type: 'success'
      });
      
      const event = document.querySelector('[data-event-id="event1"]');
      expect(event.querySelector('.event-title').textContent).toBe('Updated Event');
      expect(event.classList.contains('event-type-success')).toBe(true);
    });
  });
  
  describe('Layout Management', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('switches orientation', () => {
      component.setOrientation('horizontal');
      
      const timeline = document.querySelector('.timeline');
      expect(timeline.classList.contains('horizontal')).toBe(true);
      expect(timeline.classList.contains('vertical')).toBe(false);
    });
    
    it('handles responsive layout', () => {
      // Simulate narrow viewport
      global.innerWidth = 480;
      fireEvent(window, new Event('resize'));
      
      const timeline = document.querySelector('.timeline');
      expect(timeline.classList.contains('compact')).toBe(true);
      
      // Simulate wide viewport
      global.innerWidth = 1024;
      fireEvent(window, new Event('resize'));
      
      expect(timeline.classList.contains('compact')).toBe(false);
    });
  });
  
  describe('Event Interaction', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('handles event selection', () => {
      const event = document.querySelector('.timeline-event');
      fireEvent.click(event);
      
      expect(event.classList.contains('selected')).toBe(true);
      expect(component.getSelectedEvent()).toBe('event1');
    });
    
    it('emits event click', () => {
      const clickHandler = sinon.spy();
      component.on('eventClick', clickHandler);
      
      const event = document.querySelector('.timeline-event');
      fireEvent.click(event);
      
      expect(clickHandler.calledWith(mockEvents[0])).toBe(true);
    });
  });
  
  describe('Time Display', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('toggles time display', () => {
      component.setShowTime(false);
      
      const timestamps = document.querySelectorAll('.event-time');
      timestamps.forEach(timestamp => {
        expect(timestamp.style.display).toBe('none');
      });
    });
    
    it('formats time display', () => {
      component.setTimeFormat('HH:mm');
      
      const timestamp = document.querySelector('.event-time');
      expect(timestamp.textContent).toBe('10:00');
    });
  });
  
  describe('Filtering and Sorting', () => {
    beforeEach(() => {
      component.initialize();
    });
    
    it('filters events by type', () => {
      component.filterByType('success');
      
      const events = document.querySelectorAll('.timeline-event:not(.hidden)');
      expect(events.length).toBe(1);
      expect(events[0].getAttribute('data-event-id')).toBe('event2');
    });
    
    it('sorts events by timestamp', () => {
      component.sortEvents('desc');
      
      const events = document.querySelectorAll('.timeline-event');
      expect(Array.from(events).map(e => e.getAttribute('data-event-id')))
        .toEqual(['event3', 'event2', 'event1']);
    });
  });
  
  describe('LiveView Hook Integration', () => {
    it('implements the mounted lifecycle method', () => {
      const initializeSpy = sinon.spy(component, 'initialize');
      
      component.mounted();
      expect(initializeSpy.calledOnce).toBe(true);
    });
    
    it('implements the destroyed lifecycle method', () => {
      const destroySpy = sinon.spy(component, 'destroy');
      
      component.initialize();
      component.destroyed();
      
      expect(destroySpy.calledOnce).toBe(true);
    });
  });
}); 