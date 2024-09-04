import { NgModule } from '@angular/core';
import { PreloadAllModules, RouterModule, type Routes } from '@angular/router';

const routes: Routes = [
  {
    path: 'home',
    loadChildren: async () => (await import('./home/home.module')).HomePageModule,
  },
  {
    path: '',
    redirectTo: 'home',
    pathMatch: 'full',
  },
];

@NgModule({
  imports: [RouterModule.forRoot(routes, { preloadingStrategy: PreloadAllModules })],
  exports: [RouterModule],
})
export class AppRoutingModule {}
