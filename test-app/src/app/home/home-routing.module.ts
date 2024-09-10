import { NgModule } from "@angular/core";
import { RouterModule, type Routes } from "@angular/router";

import { HomePageComponent } from "./home.page";

const routes: Routes = [
  {
    path: "",
    component: HomePageComponent,
  },
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class HomePageRoutingModule {
  constructor() {}
}
