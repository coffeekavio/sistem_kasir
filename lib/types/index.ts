export interface User {
  id: string;
  name: string;
  email: string;
  role: 'manager' | 'supervisor' | 'kasir';
  cafe_id?: string;
  createdAt?: Date;
}