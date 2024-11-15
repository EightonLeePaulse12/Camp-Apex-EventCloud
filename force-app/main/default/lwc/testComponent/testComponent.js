import { LightningElement } from 'lwc';

export default class TestComponent extends LightningElement {
renderedCallback() {
    this.template.querySelector("canvas");
}
}